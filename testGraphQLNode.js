const request = require('graphql-request').request;

const query = `
{
  Movie(title: "Inception") {
    releaseDate
    actors {
      name
    }
  }
}`

// If you want to query the schema:
const queryS = `{
  __schema {
    types {
      name
      fields {
        name
      }
    }
  }
}`

console.log("Sending query: " + query);
request('https://api.graph.cool/simple/v1/movies', query).then(data => console.log(JSON.stringify(data, null, 2)));

