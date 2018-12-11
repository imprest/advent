defmodule AdventTest do
  use ExUnit.Case
  doctest Advent
  doctest Day8

  test "greets the world" do
    assert Advent.hello() == :world
  end
end
