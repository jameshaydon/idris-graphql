# Idris-graphql

An [Idris](https://www.idris-lang.org/) client for
[GraphQL](http://graphql.org/).

For example the GraphQL schema:

```
type Query {
  Movie: Movie
}

type Movie {
  releaseDate: String
  actors: [!Actor]
}

type Actor {
  name: !String
}
```

Corresponds to a value `Movies : Schema ["Query", "Movie", "Actor"]`. We can
then build queries for that schema:

```idris
inception : Query Movies
inception = Qu
  [ "inception" ::: fieldA "Movie" [("title", "Inception")]
     (Qu [ field "releaseDate" TrivScalar
         , field "actors" $
             Qu [ field "name" TrivScalar]
         ])
  ]
```

Which corresponds to the GraphQL query:

```
Movie(title: "Inception") {
  releaseDate
  actors {
    name
  }
}
```

A query of type `Query Movies` is guaranteed to be a valid query for the schema
`Movies`.

The `request : (url : String) -> (q : Query sch) -> JS_IO (Either String
(Value.responseType q))` function results in either a network error, or a value
whose type depends on the input query. For example, `request inception` will (if
there is no network error), produce a value of type:

```idris
Maybe (Record [("Movie",
                Maybe (Record [("releaseDate", Maybe String),
                               ("actors", Maybe (List (Record [("name", String)])))]))]) : Type
```

## Goals

- [x] A type of valid GraphQL schema definitions.
- [x] A type of valid GraphQL queries which depends on the type of schema.
- [x] Format queries for sending to APIs.
- [ ] [Type
      provider](http://docs.idris-lang.org/en/latest/guides/type-providers-ffi.html)
      which reads a schema value from an SDL (Schema Defintion Language)
      text-file.
- [ ] Type provider which uses API reflection for querying an API for it's
      schema.
- [x] A request function whose return type depends on the schema of input query.
      The return type should use [extensible
      records](https://github.com/gonzaw/extensible-records).

## TODO

- [ ] Arguments in queries are completely ignored for the moment (with respect
      to the schema).
- [ ] Add more schema top-level types.
- [ ] Add implementation using [idris-http](https://github.com/uwap/idris-http)
      when targetting C (only `node` target is currently supported).

## Build

(Have `idris` and `npm` installed.)

```
npm install
idris --codegen node --build idris-graphql.ipkg 
```
