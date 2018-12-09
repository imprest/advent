defmodule Day5 do
  @doc """

    iex> Day5.react("dabACCaCBAcCcaDA")
    "dabCBAcaDA"

  """
  def part1(polymer) when is_binary(polymer) do
    discard_and_react(polymer, [], nil, nil)
  end

  def part2(polymer) do
    ?A..?Z
    |> Task.async_stream(
      fn letter ->
        {letter, byte_size(discard_and_react(polymer, letter, letter + 32))}
      end,
      ordered: false,
      max_concurrency: 6
    )
    |> Stream.map(fn {:ok, res} -> res end)
    |> Enum.min_by(&elem(&1, 1))
  end

  defp discard_and_react(polymer, letter1, letter2) do
    discard_and_react(polymer, [], letter1, letter2)
  end

  defp discard_and_react(<<letter, rest::binary>>, acc, discard1, discard2)
       when letter == discard1
       when letter == discard2,
       do: discard_and_react(rest, acc, discard1, discard2)

  defp discard_and_react(<<letter1, rest::binary>>, [letter2 | acc], discard1, discard2)
       when abs(letter1 - letter2) == 32,
       do: discard_and_react(rest, acc, discard1, discard2)

  defp discard_and_react(<<letter, rest::binary>>, acc, discard1, discard2),
    do: discard_and_react(rest, [letter | acc], discard1, discard2)

  defp discard_and_react(<<>>, acc, _discard1, _discard2),
    do: acc |> Enum.reverse() |> List.to_string()
end
