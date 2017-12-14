module JsFfi

import Js.Utils

%default total

export
require : String -> JS_IO Ptr
require s = jscall "require(%0)" (String -> JS_IO Ptr) s

export
jskey : Ptr -> String -> JS_IO Ptr
jskey = jscall "%0[%1]" (Ptr -> String -> JS_IO Ptr)

||| Get pointer at index in array.
||| Assumes the input pointer is an array.
export
getArrIdx : Ptr -> Int -> JS_IO Ptr
getArrIdx = jscall "%0[%1]" (Ptr -> Int -> JS_IO Ptr)
