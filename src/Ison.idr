module Ison

import Js.Utils
import JsFfi

%default total
%access public export

data Value
  = JOb (List (String, Value))
  | JArr (List Value)
  | JStr String
  | JInt Int
  | JDouble Double
  | JBool Bool

interc : String -> List String -> String
interc sep [] = ""
interc sep [s] = s
interc sep (x :: y :: xs) = x ++ sep ++ interc sep (y :: xs)

Show Value where
  show (JOb kvs) = assert_total $ "JOb{" ++ interc ", " (showKV <$> kvs) ++ "}"
    where showKV (k, v) = show k ++ ":" ++ show v
  show (JArr xs) = assert_total $ "JArr[" ++ interc ", " (show <$> xs) ++ "]"
  show (JStr x) = show x
  show (JInt x) = show x
  show (JDouble x) = show x
  show (JBool x) = show x

packJson : Value -> JS_IO Ptr
packJson (JOb []) = jscall "{}" (JS_IO Ptr)
packJson (JOb ((k,v) :: xs)) = do p <- assert_total $ packJson v
                                  o <- assert_total $ packJson (JOb xs)
                                  jscall "%0[%1] = %2" (Ptr -> String -> Ptr -> JS_IO ()) o k p
                                  pure o
packJson (JStr x) = pure $ believe_me x
packJson (JInt x) = pure $ believe_me x
packJson (JDouble x) = pure $ believe_me x
packJson (JArr []) = jscall "[]" (JS_IO Ptr)
packJson (JArr (x :: xs)) = do p <- assert_total $ packJson x
                               a <- assert_total $ packJson (JArr xs)
                               jscall "%0.unshift(%1)" (Ptr -> Ptr -> JS_IO ()) a p
                               pure a
packJson (JBool False) = pure $ believe_me False
packJson (JBool True) = pure $ believe_me True

interface ToJson a where
  toJson : a -> Value

ToJson Value where
  toJson = id

ToJson Int where
  toJson = JInt

ToJson Double where
  toJson = JDouble

ToJson Bool where
  toJson = JBool

ToJson String where
  toJson = JStr

-- [foldableJson] (ToJson a, Foldable f) => ToJson (f a) where
--   toJson = JArr . map toJson . toList

pack : (ToJson a) => a -> JS_IO Ptr
pack = packJson . toJson

--  JS  ->  Idris

data JSType = JSNumber
            | JSString
            | JSBoolean
            | JSArray
            | JSObject

-- get the type of a js pointer
typeOf : Ptr -> JS_IO (Maybe JSType)
typeOf JSRef = do
  res <- jscall checkType (Ptr -> JS_IO Int) JSRef
  case res of
       0 => pure $ Just JSNumber
       1 => pure $ Just JSString
       2 => pure $ Just JSBoolean
       3 => pure $ Just JSArray
       4 => pure $ Just JSObject
       _ => pure $ Nothing
where
  checkType : String
  checkType =
    """(function(arg) {
         if (typeof arg == 'number')
           return 0;
         else if (typeof arg == 'string')
           return 1;
         else if (typeof arg == 'boolean')
           return 2;
         else if (typeof arg == 'object') {
           if (arg.constructor === Array) {
             return 3;
           } else {
             return 4;
           }
         } else
           return 5;
       })(%0)"""

isDefined : Ptr -> JS_IO Bool
isDefined ptr = do i <- jscall str (Ptr -> JS_IO Int) ptr
                   pure $ i == 1
  where str = """(function(arg){if (arg === undefined) { return 0; } else { return 1; }})(%0)"""

-- returns head of array if defined, makes array tail
jsHead : Ptr -> JS_IO (Maybe Ptr)
jsHead arr = do h <- jscall "%0.shift()" (Ptr -> JS_IO Ptr) arr
                isDef <- isDefined h
                if isDef
                  then pure (Just h)
                  else pure Nothing

-- assumes pointer really is an array
jsArrList : Ptr -> JS_IO (List Ptr)
jsArrList arr = do h <- jsHead arr
                   case h of
                     Nothing => pure $ []
                     Just p  => do ps <- assert_total (jsArrList arr)
                                   pure (p :: ps)

jsToStr : Ptr -> String
jsToStr ptr = believe_me ptr

ptrToJson : Ptr -> JS_IO (Maybe Value)
ptrToJson ptr = do
  Just ty <- typeOf ptr | _ => pure Nothing
  case ty of
    JSNumber => pure $ Just $ JDouble (believe_me ptr)
    JSString => pure $ Just $ JStr (believe_me ptr)
    JSBoolean => pure $ Just $ JBool (believe_me ptr)
    JSArray => do ptrs <- jsArrList ptr
                  Just vs <- assert_total $ sequence <$> traverse ptrToJson ptrs | _ => pure Nothing
                  pure $ Just $ JArr vs
    JSObject => do js_ks <- jscall "Object.keys(%0)" (Ptr -> JS_IO Ptr) ptr
                   js_ks' <- jsArrList js_ks
                   let keys = jsToStr <$> js_ks'
                   ps <- jscall "Object.values(%0)" (Ptr -> JS_IO Ptr) ptr >>= jsArrList
                   Just vals <- assert_total $ sequence <$> traverse ptrToJson ps | _ => pure Nothing
                   pure $ Just $ JOb $ zip keys vals

interface FromJson a where
  fromJson : Value -> Maybe a

FromJson Value where
  fromJson = Just

unpack : (FromJson a) => Ptr -> JS_IO (Maybe a)
unpack ptr = do Just j <- ptrToJson ptr | _ => pure Nothing
                pure $ fromJson j

--

FromJson String where
  fromJson (JStr s) = Just s
  fromJson _        = Nothing

FromJson Double where
  fromJson (JDouble d) = Just d
  fromJson _ = Nothing

FromJson Int where
  fromJson (JInt i) = Just i
  fromJson _ = Nothing

FromJson Bool where
  fromJson (JBool b) = Just b
  fromJson _ = Nothing

key : String -> Value -> Maybe Value
key k (JOb kvs) = lookup k kvs
key _ _ = Nothing

||| Non-destructively returns list of pointers if pointer is an array, else
||| returns Nothing.
ptrIsList : Ptr -> JS_IO (Maybe (List Ptr))
ptrIsList x = do
  Just JSArray <- typeOf x | _ => pure Nothing
  n <- jscall "%0.length" (Ptr -> JS_IO Int) x
  xs <- sequence [ getArrIdx x i | i <- [0..n-1]]
  pure (Just xs)
