defmodule Day3 do
  def gen_grid(x, y) do
    zeroed_row = 0..y |> Enum.reduce([], fn _, acc -> [0 | acc] end)

    Enum.reduce(0..x, %{}, fn r, acc ->
      Map.put_new(acc, r, List.to_tuple(zeroed_row))
    end)
  end

  @doc """
  Over claimed inches

  ## Examples
      iex> claims = String.split("#1 @ 1,3: 4x4|#2 @ 3,1: 4x4|#3 @ 5,5: 2x2", "|")
      iex> Day3.unique_id(Day3.gen_grid(8, 8), claims)
      3
  """
  def unique_id(grid \\ gen_grid(8, 8), claims) do
    c = Enum.map(claims, &parse_claim/1)

    g = Enum.reduce(c, grid, fn x, acc -> update_grid(x, acc) end)

    t = Enum.find(c, fn x -> is_unique_id(x, g) end)
    elem(t, 0)
  end

  defp is_unique_id({_, x, y, w, h}, g) do
    r =
      Enum.reduce(y..(y + (h - 1)), [], fn i, acc ->
        tuple = Map.get(g, i)
        list = Enum.reduce(x..(x + (w - 1)), [], fn t, a -> [elem(tuple, t) | a] end)
        [list | acc]
      end)

    answer =
      List.flatten(r)
      |> Enum.any?(fn j -> j > 1 end)

    !answer
  end

  @doc """
  Over claimed inches

  ## Examples
      iex> claims = String.split("#1 @ 1,3: 4x4|#2 @ 3,1: 4x4|#3 @ 5,5: 2x2", "|")
      iex> Day3.over_claimed(Day3.gen_grid(8, 8), claims)
      4
  """
  def over_claimed(grid \\ gen_grid(8, 8), claims) do
    claims
    |> Enum.map(&parse_claim/1)
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

  defp update_grid({_, _, _, _, 0}, grid) do
    grid
  end

  defp update_grid({id, x, y, w, h}, grid) do
    update_grid(
      {id, x, y + 1, w, h - 1},
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

  defp parse_claim(claim) do
    [id, x, y, w, h] = :binary.split(claim, ["#", " @ ", ",", ": ", "x"], [:trim_all, :global])

    {:erlang.binary_to_integer(id), :erlang.binary_to_integer(x), :erlang.binary_to_integer(y),
     :erlang.binary_to_integer(w), :erlang.binary_to_integer(h)}
  end
end
