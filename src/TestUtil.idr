module TestUtil

%default total

export
assertEq : Eq a => (given : a) -> (expected : a) -> IO Unit
assertEq g e = if g == e
  then putStrLn "Test Passed"
  else putStrLn "Test Failed"
