module Schema

import public Data.List

%default total
%access public export -- TODO fix this

-- TODO: Not handling arguments in queries at all.

||| An enum is just a list of values.
EnumTy : Type
EnumTy = List String

||| Built-in scalar types.
data ScalarTy =
    SInt
  | SFloat
  | SString
  | SBoolean
  | SID

scalar : ScalarTy -> Type
scalar SInt = Int
scalar SFloat = Double
scalar SString = String
scalar SBoolean = Bool
scalar SID = String

||| A proof that the first list is the end of the second list.
data IsEnd : (xs : List a) -> (ys : List a) -> Type where
  IsAll : IsEnd xs xs
  Prefix : IsEnd xs ys -> IsEnd xs (y :: ys)

isEndPost : IsEnd (x :: xs) ys -> IsEnd xs ys
isEndPost IsAll = Prefix IsAll
isEndPost (Prefix pf) = let pf' = isEndPost pf
                        in Prefix pf'

||| A proof that the first list is the `map fst` of the second.
data IsProj1 : (xs : List a) -> (ys : List (a,b)) -> Type where
  EmptyProj1 : IsProj1 [] []
  NextProj1 : IsProj1 xs ys -> IsProj1 (x :: xs) ((x,y) :: ys)

mutual

  ||| A GraphQl type.
  data GqlTy : List String -> Type where
    Scalar : ScalarTy -> GqlTy s
    TyRef : (n : String) -> {auto pf : Elem n s} -> GqlTy s
    Ob : (List (String, TyMod s)) -> GqlTy s
    Enum : EnumTy -> GqlTy s

  ||| A GraphQL type with modifiers applied. These are types that are used in
  ||| fields.
  data TyMod : List String -> Type where
    MSimple : GqlTy s -> TyMod s
    MNonNull : TyMod s -> TyMod s
    MList : TyMod s -> TyMod s

mutual
  ||| A valid GraphQL schema.
  data Schema : List String -> Type where
    MkSchema : (schema : List (String, GqlTy ns)) -> {auto pf : IsProj1 ns schema} -> Schema ns

  ||| A partial GraphQL schema.
  data PartialSchema : {ns, ns' : List String} -> (s : Schema ns) -> (ns' : List String) -> {auto pf : IsEnd ns' ns} -> Type where
    MkPSchema : {ns  : List String} ->
                {ns' : List String} ->
                {auto isEnd : IsEnd ns' ns} ->
                (tops : List (String, GqlTy ns)) ->
                {auto isValid : IsProj1 ns' tops } ->
                PartialSchema s ns'

||| The shape of a query: either it is a leaf, or its a spec for fields of an
||| object type.
data QueryKind : (s : Schema ns) -> Type where
  Trivial : QueryKind s
  Object : List (String, TyMod ns) -> QueryKind s

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
subQuery : (s : Schema ns) -> TyMod ns -> QueryKind s
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
                   Query s (subQuery s fTy) ->
                   {auto pf : Elem (field, fTy) fields} ->
                   QueryField s fields

  ||| Valid GraphQL queries for a certain schema.
  data Query : (s : Schema ns) -> (qk : QueryKind s) -> Type where
    Qu : List (QueryField s fields) -> Query s (Object fields)
    Triv : Query s Trivial

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
    ++ indent (format s x)
  formatComp (MkQueryField (Just a) field args x) = [ a ++ ": " ++ field ++ formatArgs args ]

  formatComps : {s : Schema ns} -> (xs : List (QueryField s fields)) -> Format
  formatComps [] = []
  formatComps (x :: xs) =
       formatComp x
    ++ formatComps xs

  format : (sch : Schema ns) -> Query sch k -> Format
  format sch (Qu xs) = wrap ((formatComps xs))
  format sch Triv = []

||| Format a query to a string ready to be used be sent to a GraphQL server.
fmt : Query sch k -> String
fmt {sch} q = unlines (format sch q)
