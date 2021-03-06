# IdeaZone

IdeaZone is a simple webapp that enables a community to share and vote on ideas, questions, issues... The specific feature of this app is that submitting contents and votes is anonymous (it however only provides a basic level of anonymity and doesn't prevent malicious users from submitting multiple votes).

## Getting started

### Prerequisites

Dependencies:

- Elixir 1.2.6
- PostgreSQL 9.5

Add an user to your PostgreSQL database (matches the config in `dev.exs` and `test.exs`). `SUPERUSER` is needed because some migrations will require to be able to create extensions (`0160418232000_setup_content_search.exs`).

```
psql -d postgres
psql> CREATE USER idea_zone WITH SUPERUSER PASSWORD 'idea_zone';
```

### Start

```
# Install dependencies
mix deps.get

# Create and migrate the database
mix ecto;create && mix ecto.migrate

# Start
mix phoenix.server # or bin/server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Run tests

```
bin/test
```

_NB: tests have been written using CasperJS to be as high-level as possible._

## Deployment

Follow the [Phoenix deployment guides](http://www.phoenixframework.org/docs/deployment) or the following ones.

### Heroku

You must set the `IDEA_ZONE_ADMIN_PASSWORD` environment variable (defaults to "password" in development environment).

```
# Setup Heroku buildpacks
heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git" <YOUR_APP_NAME>
heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static.git

# Add PostgreSQL addon
heroku addons:create heroku-postgresql:hobby-dev

# Set environment variables
heroku config:set HOST=<YOUR_HOST>
heroku config:set MIX_ENV=prod
heroku config:set SECRET_KEY_BASE="`mix phoenix.gen.secret`"
heroku config:set IDEA_ZONE_ADMIN_PASSWORD="<YOUR_PASSWORD>"

# Deploy the code
git push heroku deploy-heroku:master

# Perform the database migration
heroku run mix ecto.migrate
```

## Implementation details

- The `EnsureSessionToken` plug is used to ensure every user gets a session token before voting, so that we can ensure a single vote is permitted per content (except of course the user clears its cookie...).
- The admin area is protected by a password set as an environment variable of the application. The admin logged in status is stored in the session cookie too (so security is pretty low) and handled by the `EnsureAdmin` plug.
- The `AdminSession` virtual model handles the password validation.
