module Query

import GraphQL.Schema

%default total
%access public export -- TODO fix this

||| The shape of a query: either it is a leaf, or its a spec for fields of an
||| object type.
data SubQuerySort : (s : Schema ns) -> Type where
  Trivial : SubQuerySort s
  Object : List (String, TyMod ns) -> SubQuerySort s

subQ : (tops : List (String, GqlTy ns)) ->
       (n : String) ->
       (isElem : Elem n ns') ->
       {auto isEnd : IsEnd ns' ns} ->
       {auto isProj : IsProj1 ns' tops} ->
       GqlTy ns
subQ {ns' = n :: _} ((n, fTy) :: ys) n Here {isEnd = IsAll}    {isProj = NextProj1 _} = fTy
subQ {ns' = n :: _} ((n, fTy) :: ys) n Here {isEnd = Prefix x} {isProj = NextProj1 _} = fTy
subQ {ns' = _ :: _} (_ :: tops) n (There later) {isEnd = IsAll}        {isProj = NextProj1 pf} =
  subQ tops n later
subQ {ns' = _ :: _} (_ :: tops) n (There later) {isEnd = Prefix isEnd} {isProj = NextProj1 pf} =
  subQ tops n later {isEnd = Prefix (isEndPost isEnd)}

||| Given a schema and a field-type, computes the query-kind needed for the
||| sub=query at that field.
subQuery : (s : Schema ns) -> TyMod ns -> SubQuerySort s
subQuery s (MNonNull x) = subQuery s x
subQuery s (MList x) = subQuery s x
subQuery s (MSimple (Scalar x)) = Trivial
subQuery s (MSimple (Enum xs)) = Trivial
subQuery s (MSimple (Ob xs)) = Object xs
subQuery s@(MkSchema tops {pf = isProj}) (MSimple (TyRef n {pf})) =
  -- NOTE: we need the `assert_total` here because our schema type isn't precise
  -- enough. In actuality, a toplevel can only refer to an object type (or an
  -- enum, or scalar, but definitely not a type-reference).
  -- TODO: Refine schema toplevel types.
  assert_total $
    subQuery s (MSimple (subQ tops n pf))

mutual
  data QueryField : (s : Schema ns) -> (fields : List (String, TyMod ns)) -> Type where
    MkQueryField : {ns : List String} ->
                   {s : Schema ns} ->
                   (alias : Maybe String) ->
                   (field : String) ->
                   {fTy : TyMod ns} ->
                   (args : List (String, String)) ->
                   SubQuery s (Query.subQuery s fTy) ->
                   {auto pf : Elem (field, fTy) fields} ->
                   QueryField s fields

  ||| Valid GraphQL queries for a certain schema.
  data SubQuery : (s : Schema ns) -> (qk : SubQuerySort s) -> Type where
    Qu : List (QueryField s fields) -> SubQuery s (Object fields)
    Triv : SubQuery s Trivial

||| A top-level query is a sub-query on the "Query" object.
Query : Schema ns -> {auto pf : Elem "Query" ns} -> Type
Query sch = SubQuery sch (subQuery sch (MSimple (TyRef "Query")))

-- Helper functions for making queries

infixl 0 :::
(:::) : (alias : String) -> QueryField s fields -> QueryField s fields
(:::) alias (MkQueryField _ f args q) = MkQueryField (Just alias) f args q

field : (f : String) -> {auto pf : Elem (f, fTy) fields} -> SubQuery s (Query.subQuery s fTy) -> QueryField s fields
field f q = MkQueryField Nothing f [] q

fieldA : (f : String) ->
         (args : List (String, String)) ->
         {auto pf : Elem (f, fTy) fields} ->
         SubQuery s (Query.subQuery s fTy) -> QueryField s fields
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

  format : (sch : Schema ns) -> SubQuery sch k -> Format
  format sch (Qu xs) = wrap ((formatComps xs))
  format sch Triv = []

||| Format a query to a string ready to be used be sent to a GraphQL server.
fmt : Query sch -> String
fmt {sch} q = unlines (format sch q)
