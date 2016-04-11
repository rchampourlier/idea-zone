# IdeaZone

To start your Phoenix app:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Implementation details

- The `SessionToken` plug is used to ensure every user gets a session token before voting, so that we can ensure a single vote is permitted per content (except of course the user clears its cookie...).
- The admin area is protected by a password set as an environment variable of the application. The admin logged in status is stored in the session cookie too (so security is pretty low) and handled by the `EnsureAdmin` plug.
- The `AdminSession` virtual model handles the password validation.

## Deployment

- You must set the `IDEA_ZONE_ADMIN_PASSWORD` environment variable (defaults to "password" in development environment).
