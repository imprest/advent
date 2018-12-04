defmodule Day1Test do
  use ExUnit.Case

  test "final_freq" do
    assert Day1.repeated_freq([
             "+1\n",
             "-2\n",
             "+3\n",
             "+1\n"
           ]) == 2
  end
end
