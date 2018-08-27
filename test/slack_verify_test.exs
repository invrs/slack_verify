defmodule SlackVerifyTest do
  use ExUnit.Case
  doctest SlackVerify

  test "greets the world" do
    assert SlackVerify.hello() == :world
  end
end
