import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :youtube_summarizer, YoutubeSummarizer.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "youtube_summarizer_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :youtube_summarizer, YoutubeSummarizerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "m534+611cPSW4+iwhPDEz3qHmpT6BoHGRaSej+vRM+Hvh2EXCR+Rjacz/JBuM3e1",
  server: false

# In test we don't send emails
config :youtube_summarizer, YoutubeSummarizer.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
