use Mix.Config

config :logger, :console,
  level: :debug

config :cog,
  adapter: Cog.Adapters.Slack

config :cog, Cog.Adapters.Slack,
  rtm_token: System.get_env("SLACK_RTM_TOKEN"),
  api_token: System.get_env("SLACK_API_TOKEN"),
  api_cache_ttl: System.get_env("SLACK_API_CACHE_TTL")

config :emqttd, :listeners,
  [{:mqtt, 1883, [acceptors: 16,
                  max_clients: 64,
                  access: [allow: :all],
                  sockopts: [backlog: 8,
                             ip: "127.0.0.1",
                             recbuf: 4096,
                             sndbuf: 4096,
                             buffer: 4096]]}]

config :cog, Cog.Endpoint,
  http: [port: 4000],
  debug_errors: false,
  cache_static_lookup: false,
  check_origin: false

config :cog, Cog.Passwords,
  # 4-round hashing for dev only
  salt: "$2b$04$me8.bWW9urIiJbTLCCDt1."