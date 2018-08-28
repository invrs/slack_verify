defmodule SlackVerifyTest do
  use ExUnit.Case, async: true
  import Plug.Conn, only: [ put_req_header: 3 ]
  use Plug.Test

  # dummy key and signature provided in verification walkthrough
  @secret "8f742231b10e8888abcd99yyyzzz85a5"
  @signature "v0=a2114d57b48eac39b9ad189dd8316235a7b4a8d21a10bd27519666489c69b503"

  test "verifies a Slack request" do
    body = File.read!("./test/fixtures/body.txt") |> String.trim()
    conn = conn(:post, "/", %{})
    conn =
      update_in(conn.assigns[:raw_body], &[body | (&1 || [])])
      |> put_req_header("x-slack-request-timestamp", "1531420618")
      |> put_req_header("x-slack-signature", @signature)

    opts = SlackVerify.init([slack_signing_secret: @secret])
    conn = SlackVerify.call(conn, opts)

    refute conn.halted
  end
end
