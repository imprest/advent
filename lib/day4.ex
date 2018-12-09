defmodule FrequencyMap do
  defstruct data: %{}

  def new do
    %FrequencyMap{}
  end

  def most_frequent(%FrequencyMap{data: data}) do
    if data != %{} do
      Enum.max_by(data, fn {_, count} -> count end)
    else
      :error
    end
  end

  defimpl Collectable do
    def into(%FrequencyMap{data: data}) do
      collector_fun = fn
        data, {:cont, elem} -> Map.update(data, elem, 1, &(&1 + 1))
        data, :done -> %FrequencyMap{data: data}
        _, :halt -> :ok
      end

      {data, collector_fun}
    end
  end
end

defmodule Day4 do
  def part1(logs) do
    grouped_entries =
      logs
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_log/1)
      |> Enum.sort()
      |> group_by_id_and_date([])

    id_asleep_the_most =
      grouped_entries
      |> sum_asleep_times_by_id()
      |> id_asleep_the_most

    {minute_asleep_the_most, _times} =
      minute_asleep_the_most_by_id(grouped_entries, id_asleep_the_most)

    id_asleep_the_most * minute_asleep_the_most
  end

  defp group_by_id_and_date([{date, _hour, _minute, {:shift, id}} | rest], groups) do
    {rest, ranges} = get_asleep_ranges(rest, [])
    group_by_id_and_date(rest, [{id, date, ranges} | groups])
  end

  defp group_by_id_and_date([], groups) do
    Enum.reverse(groups)
  end

  defp get_asleep_ranges([{_, _, down_minute, :down}, {_, _, up_minute, :up} | rest], ranges) do
    get_asleep_ranges(rest, [down_minute..(up_minute - 1) | ranges])
  end

  defp get_asleep_ranges(rest, ranges) do
    {rest, Enum.reverse(ranges)}
  end

  defp sum_asleep_times_by_id(grouped_entries) do
    Enum.reduce(grouped_entries, %{}, fn {id, _date, ranges}, acc ->
      time_asleep = ranges |> Enum.map(&Enum.count/1) |> Enum.sum()
      Map.update(acc, id, time_asleep, &(&1 + time_asleep))
    end)
  end

  defp id_asleep_the_most(map) do
    {id, _} = Enum.max_by(map, fn {_, time_asleep} -> time_asleep end)
    id
  end

  def minute_asleep_the_most_by_id(grouped_entries, id) do
    frequency_map =
      for {^id, _, ranges} <- grouped_entries,
          range <- ranges,
          minute <- range,
          do: minute,
          into: FrequencyMap.new()

    FrequencyMap.most_frequent(frequency_map)
  end

  defp parse_log(log) do
    [timestamp, event] = String.split(log, "] ")
    [y, m, d, h, min] = :binary.split(timestamp, ["[", "-", " ", ":"], [:trim_all, :global])

    {{:erlang.binary_to_integer(y), :erlang.binary_to_integer(m), :erlang.binary_to_integer(d)},
     :erlang.binary_to_integer(h), :erlang.binary_to_integer(min), parse_event(event)}
  end

  defp parse_event("falls asleep") do
    :down
  end

  defp parse_event("wakes up") do
    :up
  end

  defp parse_event(event) do
    [guard] = :binary.split(event, ["Guard #", " begins shift"], [:trim_all, :global])
    {:shift, :erlang.binary_to_integer(guard)}
  end

  def part2(input) do
    {id, minute} =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_log/1)
      |> Enum.sort()
      |> group_by_id_and_date([])
      |> minute_asleep_the_most()

    id * minute
  end

  defp minute_asleep_the_most(grouped_entries) do
    {current_id, current_minute, _, _} =
      Enum.reduce(grouped_entries, {0, 0, 0, MapSet.new()}, fn {id, _, _}, acc ->
        {current_id, current_minute, current_count, seen_ids} = acc

        if id in seen_ids do
          acc
        else
          case minute_asleep_the_most_by_id(grouped_entries, id) do
            {minute, count} when count > current_count ->
              IO.inspect(binding())

              {id, minute, count, MapSet.put(seen_ids, id)}

            _ ->
              {current_id, current_minute, current_count,
               MapSet.put(seen_ids, :erlang.binary_to_integer(id))}
          end
        end
      end)

    {current_id, current_minute}
  end
end
