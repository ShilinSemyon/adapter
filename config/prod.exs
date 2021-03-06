use Mix.Config

# config :adapter, Adapter.Endpoint,
#  load_from_system_env: true,
#  url: [host: "...", port: 443],
#  root: ".",
#  cache_static_manifest: "priv/static/cache_manifest.json"

config :adapter, Adapter.Endpoint,
  load_from_system_env: true,
  http: [port: 4000],
  url: [host: "...", port: 443],
  code_reloader: false,
  root: ".",
  version: Application.spec(:adapter, :vsn)

config :adapter, Adapter.Endpoint, server: true

# Do not print debug messages in production
config :logger, level: :info

config :adapter, Adapter.BotLogger, type: :console

config :telegram_engine, Engine.Telegram, logger: Adapter.BotLogger

config :viber_engine, Engine.Viber, logger: Adapter.BotLogger

config :slack_engine, Engine.Slack, logger: Adapter.BotLogger

config :adapter,
  env: :prod

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :adapter, AdapterWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :adapter, AdapterWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :adapter, AdapterWeb.Endpoint, server: true
#

# Finally import the config/prod.secret.exs
# which should be versioned separately.

# config :telegram_engine, Engine.Telegram,
#       method: :polling

import_config "prod.secret.exs"
