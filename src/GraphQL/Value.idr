module Value

import GraphQL.Schema
import GraphQL.Query

%default total
%access public export

||| A record
data Record : List (String, Type) -> Type where
  Nil :  Record []
  (::) : (x : t) -> Record fields -> Record ((f,t) :: fields)

mutual
  nonNull : Type -> TypMod -> Type
  nonNull t Atom = t
  nonNull t (NonNull x) = typMod t x
  nonNull t (List x) = List (typMod t x)

  typMod : Type -> TypMod -> Type
  typMod t Atom = Maybe t
  typMod t (NonNull x) = nonNull t x
  typMod t (List x) = Maybe (List (typMod t x))

rty : (s : Schema ns) -> RTy ns -> Type
rty s (RScalar x) = scalar x
rty s (REnum xs) = (x ** Elem x xs)
rty s (ROb xs) = Record (map tyF xs)
  where
    tyF : (String, GqlTy ns, TypMod) -> (String, Type)
    -- TODO: get rid of assert_total
    tyF (field, t, mod) = assert_total (field, typMod (rty s (subQuery s t)) mod)

responseType : (q : SubQuery sch rty tyMod) -> Type
responseType {sch} q {rty = r} {tyMod = m} = typMod (rty sch r) m



