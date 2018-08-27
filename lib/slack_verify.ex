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
    slack_signing_secret = Keyword.fetch!(opts, :slack_signing_secret)
    IO.inspect(conn)
    case Plug.Conn.read_body(conn) |> IO.inspect() do
      {:ok, body, conn} ->
        { signature, timestamp } = get_headers(conn)
        sig_basestring = Enum.join([@version, timestamp, body], ":")

        hmac = sha256(slack_signing_secret, sig_basestring)
        if valid_signature?(hmac, signature),
          do: conn, else: conn |> put_status(401) |> halt()

      {:error, reason} ->
        Logger.error("Could not read request body: #{reason}")
        conn |> put_status(400) |> halt()
    end
  end

  defp valid_signature?(hmac, [ signature ]),
    do: String.downcase("#{@version}=#{hmac}") == signature
  defp valid_signature?(_hmac, _signature), do: false

  defp sha256(key, string) do
    :sha256
    |> :crypto.hmac(key, string)
    |> Base.encode16
  end

  defp get_headers(conn) do
    {
      Plug.Conn.get_req_header(conn, "x-slack-signature"),
      Plug.Conn.get_req_header(conn, "x-slack-request-timestamp")
    }
  end
end
