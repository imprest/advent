defmodule Day11 do
  @spec part1(integer(), any(), any(), integer(), any()) :: any()
  def part2(w \\ 300, h \\ 300, serial \\ 9810) do
    grid = gen_grid(w, h, serial)

    # Brute forced it with inspect... figured 13x13 or 13th pass
    # gives the most optimal power level
    for x1 <- 1..14,
        do: {x1, get_max_power(w, h, grid, x1, x1)}
  end

  defp get_max_power(w, h, grid, x1, y1) do
    result =
      for x <- 1..(w - x1 + 1),
          y <- 1..(h - y1 + 1),
          do: {{x, y}, total_power(grid, {x, y}, x1, y1)},
          into: %{}

    result
    |> Map.to_list()
    |> Enum.max_by(&elem(&1, 1))
  end

  def part1(w \\ 300, h \\ 300, serial \\ 9810, x1 \\ 3, y1 \\ 3) do
    grid = gen_grid(w, h, serial)

    result =
      for x <- 1..(w - x1 + 1),
          y <- 1..(h - y1 + 1),
          do: {{x, y}, total_power(grid, {x, y}, x1, y1)},
          into: %{}

    result
    |> Map.to_list()
    |> Enum.max_by(&elem(&1, 1))
  end

  defp total_power(grid, {x, y}, x1, y1) do
    Enum.reduce(x..(x + x1 - 1), 0, fn i, acc ->
      total =
        Enum.reduce(y..(y + y1 - 1), 0, fn j, count ->
          count + Map.get(grid, {i, j})
        end)

      total + acc
    end)
  end

  defp gen_grid(w, h, serial) do
    for x <- 1..w,
        y <- 1..h,
        do: {{x, y}, power_level(x, y, serial)},
        into: %{}
  end

  defp power_level(x, y, serial) do
    rack_id = x + 10

    rack_id
    |> Kernel.*(y)
    |> Kernel.+(serial)
    |> Kernel.*(rack_id)
    |> rem(1000)
    |> div(100)
    |> Kernel.-(5)
  end

  def part3(input) do
    serial = String.to_integer(input)
    t = :ets.new(:t, [])
    :ets.insert(t, {:best, {0, 0, 0, -10000}})
    build_table(t, serial)

    Enum.each(1..30, fn s ->
      Enum.each(1..(300 - s), fn x ->
        Enum.each(1..(300 - s), fn y ->
          power =
            value_at(t, x, y) - value_at(t, x - s, y) - value_at(t, x, y - s) +
              value_at(t, x - s, y - s)

          [{:best, {_, _, _, p}}] = :ets.lookup(t, :best)

          if power > p do
            :ets.insert(t, {:best, {x - s + 1, y - s + 1, s, power}})
          end
        end)
      end)
    end)

    [{:best, {x, y, size, power}}] = :ets.lookup(t, :best)
    "#{x},#{y},#{size} @ #{power}"
  end

  defp value_at(t, x, y) do
    case :ets.lookup(t, {x, y}) do
      [] -> 0
      [{_, v}] -> v
    end
  end

  defp build_table(t, serial) do
    Enum.each(1..300, fn x ->
      Enum.each(1..300, fn y ->
        :ets.insert(t, {
          {x, y},
          power_level(x, y, serial) + value_at(t, x - 1, y) + value_at(t, x, y - 1) -
            value_at(t, x - 1, y - 1)
        })
      end)
    end)
  end
end
