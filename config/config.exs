# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :pets, :scopes,
  usuario: [
    default: true,
    module: Pets.Cuentas.Scope,
    assign_key: :current_scope,
    access_path: [:usuario, :id],
    schema_key: :usuario_id,
    schema_type: :id,
    schema_table: :usuario,
    test_data_fixture: Pets.CuentasFixtures,
    test_setup_helper: :register_and_log_in_usuario
  ]

config :pets,
  ecto_repos: [Pets.Repo],
  generators: [timestamp_type: :utc_datetime],
  access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY"),
  bucket: System.fetch_env!("S3_BUCKET_NAME"),
  region: System.fetch_env!("AWS_REGION")

# Configures the endpoint
config :pets, PetsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: PetsWeb.ErrorHTML, json: PetsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Pets.PubSub,
  live_view: [signing_salt: "35lAJf79"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :pets, Pets.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  pets: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  pets: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Gettext to use Spanish as default locale
config :gettext, :default_locale, "es"
config :pets, PetsWeb.Gettext, default_locale: "es"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
