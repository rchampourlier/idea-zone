use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :idea_zone, IdeaZone.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :idea_zone, IdeaZone.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "idea_zone",
  password: "idea_zone",
  database: "idea_zone_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Custom config
config :idea_zone,
  admin_password: "password"
