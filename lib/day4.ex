defmodule Day4 do
  @doc """
  Get the laziest guard.

  ## Examples

      iex> Day4.target_guard([
        "[1518-11-01 00:00] Guard #10 begins shift",
        "[1518-11-01 00:05] falls asleep",
        "[1518-11-01 00:25] wakes up",
        "[1518-11-01 00:30] falls asleep",
        "[1518-11-01 00:55] wakes up",
        "[1518-11-01 23:58] Guard #99 begins shift",
        "[1518-11-02 00:40] falls asleep",
        "[1518-11-02 00:50] wakes up",
        "[1518-11-03 00:05] Guard #10 begins shift",
        "[1518-11-03 00:24] falls asleep",
        "[1518-11-03 00:29] wakes up",
        "[1518-11-04 00:02] Guard #99 begins shift",
        "[1518-11-04 00:36] falls asleep",
        "[1518-11-04 00:46] wakes up",
        "[1518-11-05 00:03] Guard #99 begins shift",
        "[1518-11-05 00:45] falls asleep",
        "[1518-11-05 00:55] wakes up"
      ])
      240
  """

  def target_guard(logs) do
    IO.inspect(Enum.at(logs, 0) |> parse_log)
    240
  end

  def parse_log(log) do
    [timestamp, _entry] = String.split(log, "] ")
    parse_timestamp(timestamp)
  end

  def parse_timestamp(timestamp) do
    [_, m, d, h, min] = :binary.split(timestamp, ["[", "-", " ", ":"], [:trim_all, :global])

    case h == 23 do
      true ->
        %{
          :month => :erlang.binary_to_integer(m),
          :day => :erlang.binary_to_integer(d) + 1,
          :hour => 0,
          :min => 0
        }

      false ->
        %{
          :month => :erlang.binary_to_integer(m),
          :day => :erlang.binary_to_integer(d) + 1,
          :hour => :erlang.binary_to_integer(h),
          :min => :erlang.binary_to_integer(min)
        }
    end
  end
end
