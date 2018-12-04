defmodule Day2 do
  def closest(list) when is_list(list) do
    list
    |> Enum.map(&String.to_charlist/1)
    |> closest_charlists()
  end

  def closest_charlists([head | tail]) do
    Enum.find_value(tail, &one_char_diff_str(&1, head)) || closest_charlists(tail)
  end

  defp one_char_diff_str(charlist1, charlist2) do
    one_char_diff_str(charlist1, charlist2, [], 0)
  end

  defp one_char_diff_str([head | tail1], [head | tail2], same_acc, diff_count) do
    one_char_diff_str(tail1, tail2, [head | same_acc], diff_count)
  end

  defp one_char_diff_str([_ | tail1], [_ | tail2], same_acc, diff_count) do
    one_char_diff_str(tail1, tail2, same_acc, diff_count + 1)
  end

  defp one_char_diff_str([], [], same_acc, 1) do
    same_acc |> Enum.reverse() |> List.to_string()
  end

  defp one_char_diff_str([], [], _, _) do
    nil
  end

  # defp one_char_diff_str(charlist1, charlist2) do
  #   charlist1
  #   |> Enum.zip(charlist2)
  #   |> Enum.split_with(fn {cp1, cp2} -> cp1 == cp2 end)
  #   |> case do
  #     {tuples_of_codepoints, [_]} ->
  #       tuples_of_codepoints
  #       |> Enum.map(fn {cp, _} -> cp end)
  #       |> List.to_string()

  #     {_, _} ->
  #       nil
  #   end
  # end

  def checksum(list) when is_list(list) do
    {twices, thrices} =
      Enum.reduce(list, {0, 0}, fn box_id, {total_twice, total_thrice} ->
        {twice, thrice} = box_id |> count_characters() |> get_twice_and_thrice()
        {twice + total_twice, thrice + total_thrice}
      end)

    twices * thrices
  end

  def get_twice_and_thrice(characters) when is_map(characters) do
    Enum.reduce(characters, {0, 0}, fn
      {_codepoint, 2}, {_twice, thrice} -> {1, thrice}
      {_codepoint, 3}, {twice, _thrice} -> {twice, 1}
      _, acc -> acc
    end)
  end

  def count_characters(string) when is_binary(string) do
    string
    |> String.to_charlist()
    |> Enum.reduce(%{}, fn codepoint, acc ->
      Map.update(acc, codepoint, 1, &(&1 + 1))
    end)
  end
end
