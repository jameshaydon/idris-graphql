module Main

import GraphQL.Client
import GraphQL.Schema
import GraphQL.Query
import GraphQL.SchemaTests
import GraphQL.Value
import Js.ASync

%default total

mainA : ASync ()
mainA = do
  liftJS_IO $ putStrLn' (fmt inception)
  Just x <- request "https://api.graph.cool/simple/v1/movies" inception | _ => liftJS_IO (putStrLn' "Some error..")
  liftJS_IO $ putStrLn' (show x)

main : JS_IO ()
main = do
  putStrLn' "hello idris-graphql!"
  setASync_ mainA
