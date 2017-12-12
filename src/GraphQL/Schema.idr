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

||| Represents a modification to a type. For example `[Episode!]!` is
||| represented by `NonNull (List (NonNull Atom))`.
data TypMod =
    Atom
  | NonNull TypMod
  | List TypMod

mutual

  ||| A GraphQl type.
  data GqlTy : List String -> Type where
    Scalar : ScalarTy -> GqlTy s
    TyRef : (n : String) -> {auto pf : Elem n s} -> GqlTy s
    Ob : (List (String, GqlTy s, TypMod)) -> GqlTy s
    Enum : EnumTy -> GqlTy s

||| A resolved type: not a reference but could contain references.
data RTy : List String -> Type where
  RScalar : ScalarTy -> RTy s
  ROb : (List (String, GqlTy s, TypMod)) -> RTy s
  REnum : EnumTy -> RTy s

rTyToTy : RTy ns -> GqlTy ns
rTyToTy (RScalar x) = Scalar x
rTyToTy (ROb xs) = Ob xs
rTyToTy (REnum xs) = Enum xs

mutual
  ||| A valid GraphQL schema.
  data Schema : List String -> Type where
    MkSchema : (schema : List (String, RTy ns)) -> {auto pf : IsProj1 ns schema} -> Schema ns

  ||| A partial GraphQL schema.
  data PartialSchema : {ns, ns' : List String} -> (s : Schema ns) -> (ns' : List String) -> {auto pf : IsEnd ns' ns} -> Type where
    MkPSchema : {ns  : List String} ->
                {ns' : List String} ->
                {auto isEnd : IsEnd ns' ns} ->
                (tops : List (String, RTy ns)) ->
                {auto isValid : IsProj1 ns' tops } ->
                PartialSchema s ns'
