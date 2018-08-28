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

  def init(opts) do
    # For test purposes only
    # Should virtually never not check timestamps in production
    defaults = [ check_timestamp?: true ]
    Keyword.merge defaults, opts
  end

  def call(conn, opts) do
    {[ signature ], [ timestamp ]} = get_headers(conn)
    slack_signing_secret           =
      Application.get_env(:slack_verify, :slack_signing_secret)

    sig_basestring =
      [@version, timestamp, conn.assigns.raw_body]
      |> Enum.join(":")

    case "#{@version}=#{sha256(slack_signing_secret, sig_basestring)}" do
      ^signature -> check_timestamp(conn, timestamp, opts)
      _fail      -> conn |> put_status(401) |> halt()
    end
  end

  defp check_timestamp(conn, _timestamp, [check_timestamp?: false]), do: conn
  defp check_timestamp(conn, timestamp, _) do
    timestamp = timestamp |> String.to_integer() |> DateTime.from_unix!()
    now       = DateTime.utc_now()
    max_diff  = 60 * 5 # five minutes

    if abs(DateTime.diff(timestamp, now)) > max_diff do
      conn |> put_status(401) |> halt()
    else
      conn
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
