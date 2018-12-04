defmodule Day1 do
  def repeated_freq(file_stream) do
    file_stream
    |> Stream.map(fn line ->
      {int, _leftover} = Integer.parse(line)
      int
    end)
    |> Stream.cycle()
    |> Enum.reduce_while({0, MapSet.new([0])}, fn x, {curr_freq, seen_freq} ->
      new_freq = curr_freq + x

      if new_freq in seen_freq do
        {:halt, new_freq}
      else
        {:cont, {new_freq, MapSet.put(seen_freq, new_freq)}}
      end
    end)
  end

  def final_freq(file_stream) do
    file_stream
    |> Stream.map(fn line ->
      {int, _leftover} = Integer.parse(line)
      int
    end)
    |> Enum.sum()
  end
end
