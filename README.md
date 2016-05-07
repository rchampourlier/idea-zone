# IdeaZone

IdeaZone is a simple webapp that enables a community to share and vote on ideas, questions, issues... The specific feature of this app is that submitting contents and votes is anonymous (it however only provides a basic level of anonymity and doesn't prevent malicious users from submitting multiple votes).

## How to run

### In development

To start your Phoenix app:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### In production

Follow the [Phoenix deployment guides](http://www.phoenixframework.org/docs/deployment) or the following ones.

#### Heroku

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
