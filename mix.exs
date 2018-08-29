defmodule SlackVerify.MixProject do
  use Mix.Project

  def project do
    [
      app: :slack_verify,
      description: description(),
      version: "0.2.2",
      elixir: "~> 1.4",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:plug, "~> 1.0"},

      {:ex_doc, "~> 0.18.0", only: :dev}
    ]
  end

  defp description do
    """
    An elixir plug that verifies Slack requests per
    Slack's verification protocol:
    https://api.slack.com/docs/verifying-requests-from-slack
    """
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md),
      maintainers: ["Clayton Gentry"],
      licenses: ["Apache 2.0"],
      links: %{
        "Github" => "http://github.com/invrs/slack_verify",
        "Docs"   => "http://hexdocs.pm/slack_verify",
      }
    ]
  end
end
