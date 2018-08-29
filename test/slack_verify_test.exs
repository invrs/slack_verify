defmodule SlackVerifyTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  import Plug.Conn, only: [ put_req_header: 3 ]
  use Plug.Test

  # dummy key and signature provided in verification walkthrough
  @secret "8f742231b10e8888abcd99yyyzzz85a5"
  @signature "v0=a2114d57b48eac39b9ad189dd8316235a7b4a8d21a10bd27519666489c69b503"

  setup do
    Application.put_env(:slack_verify, :slack_signing_secret, @secret)
  end

  test "verifies a Slack request" do
    body = load_body()
    conn = conn(:post, "/", %{})
    conn =
      update_in(conn.assigns[:raw_body], &[body | (&1 || [])])
      |> put_req_header("x-slack-request-timestamp", "1531420618")
      |> put_req_header("x-slack-signature", @signature)

    conn = SlackVerify.call(conn, [check_timestamp?: false])

    refute conn.halted
  end

  test "invalidates requests with stale timestamp" do
    body = load_body()
    conn = conn(:post, "/", %{})
    conn =
      update_in(conn.assigns[:raw_body], &[body | (&1 || [])])
      |> put_req_header("x-slack-request-timestamp", "1531420618")
      |> put_req_header("x-slack-signature", @signature)

    conn = SlackVerify.call(conn, [])

    assert conn.halted
    assert conn.status == 401
  end

  test "halts invalid Slack request" do
    body = load_body()
    bad_signature = String.replace(@signature, "a", "b")

    conn = conn(:post, "/", %{})
    conn =
      update_in(conn.assigns[:raw_body], &[body | (&1 || [])])
      |> put_req_header("x-slack-request-timestamp", "1531420618")
      |> put_req_header("x-slack-signature", bad_signature)

    conn = SlackVerify.call(conn, [check_timestamp?: false])
    assert conn.halted
    assert conn.status == 401
  end

  test "surfaces a helpful error if secret is nil or missing" do
    Application.put_env(:slack_verify, :slack_signing_secret, nil)

    body = load_body()
    conn = conn(:post, "/", %{})
    conn =
      update_in(conn.assigns[:raw_body], &[body | (&1 || [])])
      |> put_req_header("x-slack-request-timestamp", "1531420618")
      |> put_req_header("x-slack-signature", @signature)

    assert capture_log(fn ->
      conn = SlackVerify.call(conn, [])

      assert conn.halted
      assert conn.status == 401
    end) =~ "Slack signing secret is missing"
  end

  defp load_body do
     File.read!("./test/fixtures/body.txt") |> String.trim()
  end
end
