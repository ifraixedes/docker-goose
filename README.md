Docker Goose
============

Docker image with [Golang](https://golang.org/) [Goose Database migration tool](https://github.com/steinbacher/goose)

## Why

Quite a few times I use [Docker](https://www.docker.com/) to setup the entire development environment of a project; some of them require migrations and I sometimes use Goose for them, so I needed a docker image which allows to run Goose migrations on the database docker container.

So this docker imaged cover those personal needs.

Hang on!, there are a few of Goose Docker images, why another one?

Because the ones that I found in 3 Google searches didn't fit to my needs:

* [jeffutter/goose](https://github.com/jeffutter/goose-docker): I defines an `ENTRYPOINT`, so I cannot rewrite the command to run (`goose`) with environment variables which are resolved inside the container; see [ENTTRYPOINT issue](#entrypoint-issue)
* [shopkeep/goose](https://github.com/shopkeep/goose): I don't want to build an image each time that I have to run a new migration, besides it only supports Postgres, it's a bit heavy image and it has the same `ENTRYPOINT` of the one above


### ENTRYPOINT issue

Dockerfile can define an [`ENTRYPOINT`](https://docs.docker.com/engine/reference/builder/#entrypoint), which is useful for containers which run a command, which is the case here, but I needed to run a command with an environment variable which part of its values are values of other variables available inside of the container.

[`docker run --entrypoint ...`](https://docs.docker.com/engine/reference/run/#entrypoint-default-command-to-execute-at-runtime) allow to set the `ENTRYPOINT` rewriting the value set in the _Dockerfile_ however however the string it isn't "interpreted" by the container shell, so the problem is the same.

To understand what I'm saying, let's see the specific case which I had to deal

* I use a [Makefile](https://en.wikipedia.org/wiki/Makefile) to create simple targets to run commands.
* The database run as any other container, in this case the official [Posgres Image](https://hub.docker.com/_/postgres/), and let's set `postgres` as a container name
* Because I use a Makefile, I set values of `POSTGRES_USER` and the rest of the environments variables used by the Postgres image into it.
* I want to have a Makefile target which allows me to run Goose migrations on Posgres container and I don't want to hardcode docker IP post, etc., so I link Postgres container with Goose container, hence I have to execute
 `docker run --rm --link postgres:postgres -v $(realpath db):/db ifraixedes/goose sh -c 'DB_URL=postgres://$(DB_USER):$(DB_PWD)@$$POSTGRES_PORT_5432_TCP_ADDR:$$POSTGRES_PORT_5432_TCP_PORT/$(DB_NAME)?sslmode=disable`, where those `$(..)` variables are defined in the Makefile and used by the the other targets which do something with Postgres container (e.g. Running the Postgres image) and the `$$..` are the variables defined inside of the Docker container and you probably already know are set due the linked Postgres container (`--link ...`)
* Then when that command is run, `DB_URL` is set as an environment variable and inside of Goose configuration file (`dbconf.yml`) I can use it to define the connection (`open: $DB_URL`) and Goose run the migrations as expected

Running the same command (`sh -c ...`) but set as `ENTRYPOINT` (`--entrypoint`), the `$$..` environment variables aren't interpeted, so it doesn't work


## License

MIT, read [LICENSE](https://github.com/ifraixedes/docker-goose/blob/master/LICENSE) file for more information.
