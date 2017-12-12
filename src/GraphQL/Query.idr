module Query

import GraphQL.Schema

%default total
%access public export -- TODO fix this

-- ||| The shape of a query: either it is a leaf, or its a spec for fields of an
-- ||| object type.
-- data SubQuerySort : (s : Schema ns) -> Type where
--   Trivial : SubQuerySort s
--   Object : {ns : List String} -> {s : Schema ns} -> List (String, TyMod ns) -> SubQuerySort s

subQ : (tops : List (String, RTy ns)) ->
       (n : String) ->
       (isElem : Elem n ns') ->
       {auto isEnd : IsEnd ns' ns} ->
       {auto isProj : IsProj1 ns' tops} ->
       RTy ns
subQ {ns' = n :: _} ((n, fTy) :: ys) n Here {isEnd = IsAll}    {isProj = NextProj1 _} = fTy
subQ {ns' = n :: _} ((n, fTy) :: ys) n Here {isEnd = Prefix x} {isProj = NextProj1 _} = fTy
subQ {ns' = _ :: _} (_ :: tops) n (There later) {isEnd = IsAll}        {isProj = NextProj1 pf} =
  subQ tops n later
subQ {ns' = _ :: _} (_ :: tops) n (There later) {isEnd = Prefix isEnd} {isProj = NextProj1 pf} =
  subQ tops n later {isEnd = Prefix (isEndPost isEnd)}

||| Given a schema and a field-type, computes the query-kind needed for the
||| sub=query at that field.
subQuery : (s : Schema ns) -> GqlTy ns -> RTy ns
subQuery s (Scalar x) = RScalar x
subQuery s (Enum xs) = REnum xs
subQuery s (Ob xs) = ROb xs
subQuery s@(MkSchema tops {pf = isProj}) (TyRef n {pf}) =
  -- NOTE: we need the `assert_total` here because our schema type isn't precise
  -- enough. In actuality, a toplevel can only refer to an object type (or an
  -- enum, or scalar, but definitely not a type-reference).
  -- TODO: Refine schema toplevel types.
  assert_total $
    subQuery s (rTyToTy (subQ tops n pf))

mutual
  data QueryField : (s : Schema ns) -> (fields : List (String, GqlTy ns, TypMod)) -> Type where
    MkQueryField : {ns : List String} ->
                   {s : Schema ns} ->
                   (alias : Maybe String) ->
                   (field : String) ->
                   {fTy : GqlTy ns} ->
                   (args : List (String, String)) ->
                   SubQuery s (Query.subQuery s fTy) tyMod ->
                   {auto pf : Elem (field, fTy, tyMod) fields} ->
                   QueryField s fields

  ||| Valid GraphQL queries for a certain schema.
  data SubQuery : (s : Schema ns) -> (rty : RTy ns) -> TypMod -> Type where
    Qu : List (QueryField s fields) -> SubQuery s (ROb fields) _
    TrivEnum : SubQuery s (REnum _) _
    TrivScalar : SubQuery s (RScalar _) _

||| A top-level query is a sub-query on the "Query" object.
Query : Schema ns -> {auto pf : Elem "Query" ns} -> Type
Query sch = SubQuery sch (subQuery sch (TyRef "Query")) Atom

-- Helper functions for making queries

infixl 0 :::
(:::) : (alias : String) -> QueryField s fields -> QueryField s fields
(:::) alias (MkQueryField _ f args q) = MkQueryField (Just alias) f args q

field : (f : String) -> {auto pf : Elem (f, fTy, tyMod) fields} -> SubQuery s (Query.subQuery s fTy) tyMod -> QueryField s fields
field f q = MkQueryField Nothing f [] q

fieldA : (f : String) ->
         (args : List (String, String)) ->
         {auto pf : Elem (f, fTy, tyMod) fields} ->
         SubQuery s (Query.subQuery s fTy) tyMod -> QueryField s fields
fieldA f as q = MkQueryField Nothing f as q

-- Formatting queries.

Format : Type
Format = List String

indent : Format -> Format
indent = map ("  " ++)

wrap : Format -> Format
wrap f = ["{"] ++ indent f ++ ["}"]

formatArg : (String, String) -> String
formatArg (name, val) = name ++ ": " ++ "\"" ++ val ++ "\""

formatArgs : List (String, String) -> String
formatArgs [] = ""
formatArgs as = "(" ++ formatArgs' as ++ ")"
  where
    formatArgs' [] = ""
    formatArgs' [a] = formatArg a
    formatArgs' (a::as) = formatArg a ++ ", " ++ formatArgs' as

mutual
  formatComp : {s : Schema ns} -> QueryField s fields -> Format
  formatComp {s} (MkQueryField Nothing field args x) =
       [ field ++ formatArgs args ]
    ++ (format s x)
  formatComp (MkQueryField (Just a) field args x) =
       [ a ++ ": " ++ field ++ formatArgs args ]
    ++ (format s x)

  formatComps : {s : Schema ns} -> (xs : List (QueryField s fields)) -> Format
  formatComps [] = []
  formatComps (x :: xs) =
       formatComp x
    ++ formatComps xs

  format : (sch : Schema ns) -> SubQuery sch k tyMod -> Format
  format sch (Qu xs) = wrap ((formatComps xs))
  format sch Triv = []

||| Format a query to a string ready to be used be sent to a GraphQL server.
fmt : Query sch -> String
fmt {sch} q = unlines (format sch q)
