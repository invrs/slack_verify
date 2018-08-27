# SlackVerify

SlackVerify is a plug that enables [verifying Slack requests](https://api.slack.com/docs/verifying-requests-from-slack).

Configure it with your application's Slack signing secret:
```elixir
plug SlackVerify, slack_signing_secret: System.get_env("MY_SLACK_SIGNING_SECRET")
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `slack_verify` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:slack_verify, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/slack_verify](https://hexdocs.pm/slack_verify).
