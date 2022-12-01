# FoamPit

A [Pioneer](https://github.com/d-exclaimation/pioneer/) test server that logs all HTTP requests in a readable manner. Used for testing GraphQL operations against

## Running

Pull image from [Docker Hub](https://hub.docker.com/repository/docker/dexclaimation/foam-pit/general) or clone this repository


```sh
docker run -p 4200:4200 dexclaimation/foam-pit
```

The GraphQL API is now exposed at `http://localhost:4200/graphql`

