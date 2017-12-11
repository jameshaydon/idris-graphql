module Client

import GraphQL.Schema

%inline
public export
jscall : (fname : String) -> (ty : Type) ->
         {auto fty : FTy FFI_JS [] ty} -> ty
jscall fname ty = foreign FFI_JS fname ty

require : String -> JS_IO Ptr
require s = jscall "require(%0)" (String -> JS_IO Ptr) s

-- const request = require('graphql-request').request;
client : JS_IO Ptr
client = require "graphql-request"

||| Takes a query, makes the request, and for the moment just prints the result.
export
request : String -> Query sch k -> JS_IO ()
request url q = do
  c <- client
  jscall
    "(function(c,url,q){ c.request(url,q).then(data => console.log(JSON.stringify(data, null, 2))); })(%0,%1,%2)"
    (Ptr -> String -> String -> JS_IO ())
    c
    url
    (fmt q)
