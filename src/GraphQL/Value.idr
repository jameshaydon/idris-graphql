module Value

import GraphQL.Schema
import GraphQL.Query
import JsFfi
import Ison

%default total
%access public export

namespace ResponseType
  data RespTy =
      ReScalar ScalarTy
    | ReMaybe RespTy
    | ReList RespTy
    | ReRecord (List (String, RespTy))

  data ResponseData : RespTy -> Type where
    DScalar : (scalar s) -> ResponseData (ReScalar s)
    DMaybe : Maybe (ResponseData r) -> ResponseData (ReMaybe r)
    DList : List (ResponseData r) -> ResponseData (ReList r)
    DEmptyRecord : ResponseData (ReRecord [])
    DKeyVal : (k : String) -> ResponseData r -> ResponseData (ReRecord kvs) -> ResponseData (ReRecord ((k, r) :: kvs))

Show (ResponseData rt) where
  show (DScalar x) = showScalar x
  show (DMaybe Nothing) = "null"
  show (DMaybe (Just x)) = show x
  show (DList xs) = show xs
  show DEmptyRecord = "{}"
  show (DKeyVal k x y) = assert_total $ show (k, x) ++ "-:-" ++ show y

scalarFromPtr : Ptr -> (s : ScalarTy) -> JS_IO (Maybe (Schema.scalar s))
scalarFromPtr x SInt = unpack x
scalarFromPtr x SFloat = unpack x
scalarFromPtr x SString = unpack x
scalarFromPtr x SBoolean = unpack x
scalarFromPtr x SID = unpack x

fromPtr : Ptr -> (rt : RespTy) -> JS_IO (Maybe (ResponseData rt))
fromPtr x (ReScalar s) = do
  y <- scalarFromPtr x s
  pure (DScalar <$> y)
fromPtr x (ReMaybe rt) = do
  Just y <- fromPtr x rt | _ => pure (Just (DMaybe Nothing))
  pure (Just (DMaybe (Just y)))
fromPtr x (ReList rt) = do
  Just ps <- ptrIsList x | _ => pure Nothing
  Just ys <- sequence <$> sequence [ fromPtr y rt | y <- ps ] | _ => pure Nothing
  pure (Just (DList ys))
fromPtr x (ReRecord []) = pure (Just DEmptyRecord)
fromPtr x rec@(ReRecord ((prop, rt) :: xs)) = do
  Just y <- fromPtr x (assert_smaller rec (ReRecord xs)) | _ => pure Nothing
  v_ <- jskey x prop
  Just v <- fromPtr v_ rt | _ => pure Nothing
  pure (Just (DKeyVal prop v y))

mutual
  nonNull : RespTy -> TypMod -> RespTy
  nonNull t Atom = t
  nonNull t (NonNull x) = typMod t x
  nonNull t (List x) = ReList (typMod t x)

  typMod : RespTy -> TypMod -> RespTy
  typMod t Atom = ReMaybe t
  typMod t (NonNull x) = nonNull t x
  typMod t (List x) = ReMaybe (ReList (typMod t x))

rty : (s : Schema ns) -> RTy ns -> RespTy
rty s (RScalar x) = ReScalar x
rty s (REnum xs) = ReScalar SString -- TODO add enums o RespTy and do something like: (x ** Elem x xs)
rty s (ROb xs) = ReRecord (map (\(f,t,m) => assert_total (f, typMod (rty s (subQuery s t)) m)) xs)

total
responseType : (q : SubQuery sch r m) -> RespTy
responseType {sch} {r} {m} q = typMod (rty sch r) m

{-
responseType : (q : SubQuery sch rty tyMod) -> Type
responseType {sch} q {rty = r} {tyMod = m} = respTy $ typMod (rty sch r) m
-}
