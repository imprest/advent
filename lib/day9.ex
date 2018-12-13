defmodule Day9 do
  defstruct [:scores, :players, :board]

  alias Board

  def parse(str) do
    [_, players, turns] = Regex.run(~r/(\d+) players.+ (\d+) points/, str)
    {String.to_integer(players), String.to_integer(turns)}
  end

  def new(players) do
    %__MODULE__{
      scores: %{},
      players: players,
      board: Board.new()
    }
  end

  def play(game, marble) when rem(marble, 23) == 0 do
    player = rem(marble, game.players)

    {mine, board} =
      game.board
      |> Board.move(-7)
      |> Board.pop()

    scores = Map.update(game.scores, player, mine + marble, &(&1 + mine + marble))

    %{game | board: board, scores: scores}
  end

  def play(game, marble) do
    board =
      game.board
      |> Board.move(1)
      |> Board.place(marble)

    %{game | board: board}
  end

  def play_game(players, turns) do
    Enum.reduce(1..turns, new(players), fn turn, game ->
      play(game, turn)
    end)
  end

  def high_score(%{scores: scores}) do
    scores
    |> Map.values()
    |> Enum.max()
  end
end

defmodule Board do
  defstruct [:before, :after]

  def new() do
    %__MODULE__{
      before: [0],
      after: []
    }
  end

  def place(board, marble) do
    %{board | before: [marble | board.before]}
  end

  def pop(%{before: [marble | rest]} = board) do
    {marble, move(%{board | before: rest}, 1)}
  end

  def pop(%{before: []} = board) do
    board
    |> swap()
    |> pop()
  end

  def move(%{after: []} = board, motion) when motion > 0 do
    board
    |> swap()
    |> move(motion)
  end

  def move(%{after: [h | rest]} = board, motion) when motion > 0 do
    move(%{board | after: rest, before: [h | board.before]}, motion - 1)
  end

  def move(%{before: []} = board, motion) when motion < 0 do
    board
    |> swap()
    |> move(motion)
  end

  def move(%{before: [h | rest]} = board, motion) when motion < 0 do
    move(%{board | after: [h | board.after], before: rest}, motion + 1)
  end

  def move(board, 0) do
    board
  end

  defp swap(board) do
    %{board | before: Enum.reverse(board.after), after: Enum.reverse(board.before)}
  end

  defimpl Inspect, for: __MODULE__ do
    def inspect(%{before: b = [c | _], after: a}, _opts) do
      Kernel.inspect(%{list: Enum.reverse(b) ++ a, current: c})
    end
  end
end
