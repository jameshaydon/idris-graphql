module SchemaTests

import GraphQL.Schema
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
inception : Query Movies (subQuery Movies (MSimple (TyRef "Query")))
inception = Qu
  [ MkQueryField Nothing "Movie" [("title", "Inception")]
      (Qu [ MkQueryField Nothing "releaseDate" [] Triv
          , MkQueryField Nothing "actors" []
              (Qu [ MkQueryField Nothing "name" [] Triv ])
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

libQ : Query Library (subQuery Library (MSimple (TyRef "Author")))
libQ = Qu
  [ MkQueryField Nothing "name" [] Triv
  , MkQueryField Nothing "age" [] Triv
  , MkQueryField Nothing "books" [("before", "1987")]
      (Qu [ MkQueryField Nothing "pubDate" [] Triv
          , MkQueryField Nothing "name" [] Triv
          ])
  ]

export
spec : IO ()
spec = do
  assertEq
    (fmt libQ)
    "{\n  name\n  age\n  books(before: \"1987\")\n    {\n      pubDate\n      name\n    }\n}\n"
  assertEq
    (fmt inception)
    "{\n  Movie(title: Inception)\n    {\n      releaseDate\n      actors\n        {\n          name\n        }\n    }\n}\n"
