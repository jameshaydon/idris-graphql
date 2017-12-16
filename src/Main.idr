module Main

import GraphQL.Client
import GraphQL.Schema
import GraphQL.Query
import GraphQL.SchemaTests
import GraphQL.Value
import Js.ASync

%default total

IRT : Type
IRT = ResponseData (Value.responseType Inception)

IRT' : Type
IRT' = ResponseData (ReMaybe (ReRecord [("Movie",
                                         ReMaybe (ReRecord [("releaseDate", ReMaybe (ReScalar SString)),
                                                            ("actors",
                                                             ReMaybe (ReList (ReRecord [("name",
                                                                                         ReScalar SString)])))]))]))

releaseDate : IRT -> Maybe String
releaseDate (DMaybe Nothing) = Nothing
releaseDate (DMaybe (Just (DKeyVal "Movie" (DMaybe Nothing) _))) = Nothing
releaseDate (DMaybe (Just (DKeyVal "Movie" (DMaybe (Just (DKeyVal "releaseDate" (DMaybe Nothing) _))) _))) = Nothing
releaseDate (DMaybe (Just (DKeyVal "Movie" (DMaybe (Just (DKeyVal "releaseDate" (DMaybe (Just (DScalar x))) _))) _))) = Just x

mainA : ASync ()
mainA = do
  liftJS_IO $ putStrLn' (fmt Inception)
  Just x <- request "https://api.graph.cool/simple/v1/movies" Inception | _ => liftJS_IO (putStrLn' "Some error..")
  liftJS_IO $ putStrLn' $
    case releaseDate x of
      Nothing => "There was no returned release date."
      Just rd => "The release date of the movie 'Inception' is: " ++ rd

main : JS_IO ()
main = do
  putStrLn' "hello idris-graphql!"
  setASync_ mainA
