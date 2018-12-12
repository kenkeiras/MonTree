# MonTree

MonTree is an (on progress) fork based on [TechTree](https://github.com/kenkeiras/TechTree) to explore different monitoring schemas.
If the changes are not big enough to keep a separate fork the idea is to merge it back onto TechTree.

[![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=kenkeiras/MonTree)](https://dependabot.com)

To start your server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install ; cd ..`
  * Launch a docker postgres server with `docker run -d --name techtree-postgres -p 127.0.0.1:5432:5432 postgres`
  * Create a database `docker exec --user postgres -it techtree-postgres psql -c 'create database techtree_dev;'`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `mix phx.server` or, to also get an interactive shell, `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Fast configuration & deploy

To build a docker and deploy it there (with a corresponding one for the DB) 
do the following

```bash
# Build docker image
docker -t montree .
# Launch docker image and database
sh launch-docker.sh
```

## MonTree plan on TechTree

You can check this project TechTree on https://techtree.spiral.systems/projects/82 .
