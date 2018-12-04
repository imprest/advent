defmodule Day3Test do
  use ExUnit.Case

  doctest Day3

  test "over_claimed" do
    assert Day3.over_claimed([
             "#1 @ 1,3: 4x4",
             "#2 @ 3,1: 4x4",
             "#3 @ 5,5: 2x2"
           ]) == 4
  end
end
