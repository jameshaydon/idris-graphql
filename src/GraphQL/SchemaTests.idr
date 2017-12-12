module SchemaTests

import GraphQL.Schema
import GraphQL.Query
import TestUtil

%default total

||| A fragment of the movies API which can be queried at: `http://www.graph.cool/`
||| ```
||| type Query {
|||   Movie: Movie
||| }
|||
||| type Movie {
|||   releaseDate: String
|||   actors: [!Actor]
||| }
|||
||| type Actor {
|||   name: !String
|||  }
||| ```
export
Movies : Schema ["Query", "Movie", "Actor"]
Movies = MkSchema
  [ ( "Query"
    , ROb [ ( "Movie", TyRef "Movie", Atom) ]
    )
  , ( "Movie"
    , ROb [ ("releaseDate", Scalar SString, Atom)
          , ("actors", TyRef "Actor", List (NonNull Atom)) ]
    )
  , ( "Actor"
    , ROb [ ("name", Scalar SString, NonNull Atom) ]
    )
  ]

||| A query for information about the movie "Inception".
||| ```
||| Movie(title: "Inception") {
|||   releaseDate
|||   actors {
|||     name
|||   }
||| }
||| ```
export
inception : Query Movies
inception = Qu
  [ "inception" ::: fieldA "Movie" [("title", "Inception")]
     (Qu [ field "releaseDate" TrivScalar
         , field "actors" $
             Qu [ field "name" TrivScalar]
         ])
  ]

||| An api to access information about books and authors. Tests circular
||| references in type definitions.
Library : Schema ["Actor", "Author", "Book"]
Library = MkSchema
  [ ( "Actor"
    , ROb [ ("name", Scalar SString, NonNull Atom) ]
    )
  , ( "Author"
    , ROb [ ( "name", Scalar SString, NonNull Atom)
         , ( "age", Scalar SInt, NonNull Atom)
         , ( "books", TyRef "Book", List (NonNull Atom))
         ]
    )
  , ( "Book"
    , ROb [ ("name", Scalar SString, NonNull Atom)
          , ("pubDate", Scalar SInt, NonNull Atom)
          , ("author", TyRef "Author", Atom)
          ]
    )
  ]

libQ : SubQuery Library (subQuery Library (TyRef "Author")) Atom
libQ = Qu
  [ "authorName" ::: field "name" TrivScalar
  , field "age" TrivScalar
  , fieldA "books" [("before", "1987")] $
      Qu [ field "pubDate" TrivScalar
         , field "name" TrivScalar
         ]
  ]

inceptionF : String
inceptionF =
  """{
  inception: Movie(title: \"Inception\")
  {
    releaseDate
    actors
    {
      name
    }
  }
}
"""

export
spec : IO ()
spec =
  assertEq
    (fmt inception)
    inceptionF
