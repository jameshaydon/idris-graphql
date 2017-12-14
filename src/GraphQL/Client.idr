module Client

import GraphQL.Schema
import GraphQL.Query
import GraphQL.Value
import JsFfi
import Js.ASync

%default total

client : JS_IO Ptr
client = require "graphql-request"

partial
reqP : (url : String) -> (q : Query sch) -> ASync Ptr
reqP url q = MkASync async
  where
    async : (Ptr -> JS_IO ()) -> JS_IO ()
    async cb = assert_total $ do
      c <- client
      jscall
        "(function(c,url,q,cb){ c.request(url,q).then(data => { console.log(data); cb(data);} ); })(%0,%1,%2,%3)"
        (Ptr -> String -> String -> (JsFn (Ptr -> JS_IO ())) -> JS_IO ())
        c
        url
        (fmt q)
        (MkJsFn cb)

||| Takes a query, makes the request, and for the moment just prints the result.
export
requestLog : String -> (q : Query sch) -> JS_IO ()
requestLog url q = do
  c <- client
  jscall
    "(function(c,url,q){ c.request(url,q).then(data => console.log(JSON.stringify(data, null, 2))); })(%0,%1,%2)"
    (Ptr -> String -> String -> JS_IO ())
    c
    url
    (fmt q)

||| Well-typed request function.
export
request : (url : String) -> (q : Query sch) -> ASync (Maybe (ResponseData (Value.responseType q)))
request {sch} url q = do
  let r = subQuery sch (TyRef "Query")
  let m = Atom
  let rty = typMod (rty sch r) m
  x <- reqP url q
  v <- liftJS_IO $ fromPtr x rty
  pure v
