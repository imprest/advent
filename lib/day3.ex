defmodule Day3 do
  def over_claimed(claims) do
    grid = gen_grid(8, 8)

    claims
    |> Enum.map(&parse_claims/1)
    |> Enum.reduce(grid, fn x, acc -> update_grid(x, acc) end)
    |> Enum.reduce(0, fn x, acc ->
      acc + count_overclaimed(elem(x, 1))
    end)
  end

  defp count_overclaimed(tuple) do
    count_overclaimed(tuple, 0, tuple_size(tuple), 0)
  end

  defp count_overclaimed(_, _, 0, count) do
    count
  end

  defp count_overclaimed(tuple, index, length, count) do
    if elem(tuple, index) > 1 do
      count_overclaimed(tuple, index + 1, length - 1, count + 1)
    else
      count_overclaimed(tuple, index + 1, length - 1, count)
    end
  end

  defp update_grid({_, _, _, 0}, grid) do
    grid
  end

  defp update_grid({x, y, w, h}, grid) do
    update_grid(
      {x, y + 1, w, h - 1},
      Map.update!(grid, y, &update_tuple(&1, x, x + w))
    )
  end

  defp update_tuple(tuple, start, stop) do
    if start == stop do
      tuple
    else
      p = Kernel.elem(tuple, start)
      update_tuple(Kernel.put_elem(tuple, start, p + 1), start + 1, stop)
    end
  end

  def gen_grid(x, y) do
    zeroed_row = 0..y |> Enum.reduce([], fn _, acc -> [0 | acc] end)

    Enum.reduce(0..x, %{}, fn r, acc ->
      Map.put_new(acc, r, List.to_tuple(zeroed_row))
    end)
  end

  defp parse_claims(<<"#", _id, " @ ", x, ",", y, ": ", w, "x", h, "\n">>) do
    {:erlang.binary_to_integer(<<x>>), :erlang.binary_to_integer(<<y>>),
     :erlang.binary_to_integer(<<w>>), :erlang.binary_to_integer(<<h>>)}
  end

  defp parse_claims(<<"#", _id, " @ ", x, ",", y, ": ", w, "x", h>>) do
    {:erlang.binary_to_integer(<<x>>), :erlang.binary_to_integer(<<y>>),
     :erlang.binary_to_integer(<<w>>), :erlang.binary_to_integer(<<h>>)}
  end
end
