import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :skull_king, SkullKing.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "skull_king_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :skull_king, SkullKingWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "c9+CB8HFZH29/5r0rwTWj2sfVDYw85ruaefDRhkbNPkdW5yz8+wTEWZYxXvU5KAm",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :skull_king, SkullKing.Games, SkullKing.Games.Mock
config :skull_king, SkullKing.Games.Storage, SkullKing.Games.Storage.Mock
