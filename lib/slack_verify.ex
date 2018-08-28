defmodule SlackVerify do

  import Plug.Conn
  require Logger

  @moduledoc """
  SlackVerify is a plug for verifying the
  authenticity of requests from Slack.

  It follows the protocol described in Slack's verification docs:
  https://api.slack.com/docs/verifying-requests-from-slack
  """

  @version "v0"

  def init(opts), do: opts

  def call(conn, opts) do
    slack_signing_secret           = Keyword.fetch!(opts, :slack_signing_secret)
    {[ signature ], [ timestamp ]} = get_headers(conn)

    sig_basestring =
      [@version, timestamp, conn.assigns.raw_body]
      |> Enum.join(":")

    case "#{@version}=#{sha256(slack_signing_secret, sig_basestring)}" do
      ^signature -> conn
      _fail      -> conn |> put_status(401) |> halt()
    end
  end

  defp sha256(key, string) do
    :sha256
    |> :crypto.hmac(key, string)
    |> Base.encode16(case: :lower)
  end

  defp get_headers(conn) do
    {
      Plug.Conn.get_req_header(conn, "x-slack-signature"),
      Plug.Conn.get_req_header(conn, "x-slack-request-timestamp")
    }
  end
end
