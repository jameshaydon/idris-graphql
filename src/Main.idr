module Main

import GraphQL.Client
import GraphQL.Schema
import GraphQL.SchemaTests

main : JS_IO ()
main = do
  putStrLn' "hello idris-graphql!"
  let q = fmt inception
  putStrLn' q
  request "https://api.graph.cool/simple/v1/movies" inception
