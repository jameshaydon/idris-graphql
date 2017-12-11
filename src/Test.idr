module Test

import TestUtil

import GraphQL.SchemaTests

%access public export

spec : IO ()
spec = do
  assertEq 1 1
  SchemaTests.spec
