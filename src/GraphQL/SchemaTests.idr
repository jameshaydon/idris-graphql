module SchemaTests

import GraphQL.Schema
import GraphQL.Query
import TestUtil

%default total

||| The movies API which can be queries at: `http://www.graph.cool/`
export
Movies : Schema ["Query", "Movie", "Actor"]
Movies = MkSchema
  [ ( "Query"
    , Ob [ ( "Movie", MSimple (TyRef "Movie")) ]
    )
  , ( "Movie"
    , Ob [ ("releaseDate", MSimple (Scalar SString))
         , ("actors", MList (MSimple (TyRef "Actor"))) ]
    )
  , ( "Actor"
    , Ob [ ("name", MSimple (Scalar SString)) ]
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
     (Qu [ field "releaseDate" Triv
         , field "actors" $
             Qu [ field "name" Triv]
         ])
  ]

||| An api to access information about books and authors. Tests circular
||| references in type definitions.
Library : Schema ["Actor", "Author", "Book"]
Library = MkSchema
  [ ( "Actor"
    , Ob [ ("name", MNonNull (MSimple (Scalar SString))) ]
    )
  , ( "Author"
    , Ob [ ( "name", MNonNull (MSimple (Scalar SString)))
         , ( "age", MSimple (Scalar SInt))
         , ( "books", MList (MNonNull (MSimple (TyRef "Book"))))
         ]
    )
    , ( "Book"
      , Ob [ ("name", MNonNull (MSimple (Scalar SString)))
           , ("pubDate", MSimple (Scalar SInt))
           , ("author", MSimple (TyRef "Author"))
           ]
      )
  ]

libQ : SubQuery Library (subQuery Library (MSimple (TyRef "Author")))
libQ = Qu
  [ "authorName" ::: field "name" Triv
  , field "age" Triv
  , fieldA "books" [("before", "1987")] $
      Qu [ field "pubDate" Triv
         , field "name" Triv
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
