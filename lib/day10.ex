defmodule Day10 do
  def parse(input) do
    ~r/(?:<\s*(-?\d+),\s*(-?\d+)>)/
    |> Regex.scan(input, capture: :all_but_first)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(4)
    |> Enum.map(fn [x, y, dx, dy] ->
      {{x, y}, {dx, dy}}
    end)
  end

  def solve(points) do
    seconds = time(points)
    map(points, seconds)
  end

  def time(points) do
    points
    |> do_time(height(points), 1)
  end

  defp do_time(points, prev_height, seconds) do
    positions = move(points, seconds)
    height = height(positions)

    if height > prev_height do
      seconds - 1
    else
      do_time(points, height, seconds + 1)
    end
  end

  def height(points) do
    {t, b} =
      bounds(points, fn
        {{_, y}, _} -> y
        {_, y} -> y
      end)

    b - t
  end

  def map(points, seconds) do
    points
    |> move(seconds)
    |> draw()
  end

  def move(points, seconds) do
    Enum.map(points, fn {{x, y}, {dx, dy}} ->
      {x + dx * seconds, y + dy * seconds}
    end)
  end

  def draw(positions) do
    {l, r} = bounds(positions, fn {x, _} -> x end)
    {t, b} = bounds(positions, fn {_, y} -> y end)

    Enum.map(t..b, fn y ->
      Enum.map(l..r, fn x ->
        if Enum.member?(positions, {x, y}) do
          "#"
        else
          "."
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
  end

  defp bounds(positions, fun) do
    positions
    |> Enum.map(fun)
    |> Enum.min_max()
  end
end
