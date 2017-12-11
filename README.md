# Idris-graphql

An [Idris](https://www.idris-lang.org/) client for [GraphQL](http://graphql.org/).

## Goals

- [x] A type of valid GraphQL schema definitions.
- [x] A type of valid GraphQL queries which depends on the type of schema.
- [x] Format queries for sending to APIs.
- [ ] [Type provider](http://docs.idris-lang.org/en/latest/guides/type-providers-ffi.html) which reads a schema value from an SDL (Schema Defintion Language) text-file.
- [ ] Type provider which uses API reflection for querying an API for it's schema.
- [ ] A request function whose return type depends on the schema of input query.

## TODO

- [ ] Add other sorts of arguments (only string arguments for now).
- [ ] Add more schema top-level types.

## Build

(Have `idris` and `npm` installed.)

```
npm install
idris --codegen node --build idris-graphql.ipkg 
```
