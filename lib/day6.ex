defmodule Day6 do
  def parse_coordinate(binary) when is_binary(binary) do
    [x, y] = String.split(binary, ", ")
    {String.to_integer(x), String.to_integer(y)}
  end

  def bounding_box(coordinates) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(coordinates, &elem(&1, 0))
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(coordinates, &elem(&1, 1))
    {min_x..max_x, min_y..max_y}
  end

  def closest_grid(coordinates, x_range, y_range) do
    for x <- x_range,
        y <- y_range,
        point = {x, y},
        do: {point, classify_coordinate(coordinates, point)},
        into: %{}
  end

  defp classify_coordinate(coordinates, point) do
    coordinates
    |> Enum.map(&{manhattan_distance(&1, point), &1})
    |> Enum.sort()
    |> case do
      [{0, coordinate} | _] -> coordinate
      [{distance, _}, {distance, _} | _] -> nil
      [{_, coordinate} | _] -> coordinate
    end
  end

  defp manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp infinite_coordinates(closet_grid, x_range, y_range) do
    infinite_for_x =
      for y <- [y_range.first, y_range.last],
          x <- x_range,
          closest = closet_grid[{x, y}],
          do: closest

    infinite_for_y =
      for x <- [x_range.first, x_range.last],
          y <- y_range,
          closest = closet_grid[{x, y}],
          do: closest

    MapSet.new(infinite_for_x ++ infinite_for_y)
  end

  def largest_finite_area(coordinates) do
    {x_range, y_range} = bounding_box(coordinates)
    closest_grid = closest_grid(coordinates, x_range, y_range)
    infinite_coordinates = infinite_coordinates(closest_grid, x_range, y_range)

    finite_count =
      Enum.reduce(closest_grid, %{}, fn {_, coordinate}, acc ->
        if coordinate == nil or coordinate in infinite_coordinates do
          acc
        else
          Map.update(acc, coordinate, 1, &(&1 + 1))
        end
      end)

    {_coordinate, count} = Enum.max_by(finite_count, fn {_coordinate, count} -> count end)

    count
  end

  def area_within_maximum_total_distance(coordinates, maximum_distance) do
    {x_range, y_range} = bounding_box(coordinates)

    x_range
    |> Task.async_stream(
      fn x ->
        Enum.reduce(y_range, 0, fn y, count ->
          point = {x, y}
          if sum_distances(coordinates, point) < maximum_distance, do: count + 1, else: count
        end)
      end,
      ordered: false
    )
    |> Enum.reduce(0, fn {:ok, count}, acc -> count + acc end)
  end

  defp sum_distances(coordinates, point) do
    coordinates
    |> Enum.map(&manhattan_distance(&1, point))
    |> Enum.sum()
  end
end
