defmodule Tictac.BoardTest do
  use ExUnit.Case, async: true

  doctest Tictac.Board

  test "winner" do
    assert winner_by_positions([]) == nil
    assert winner_by_positions([{0, 0}, {0, 1}, {0, 2}]) == :x
    assert winner_by_positions([{0, 0}, {0, 1}, {0, 2}], :o) == :o
  end

  test "board" do
    assert to_string(Tictac.Board.new({:x, :o, nil, nil, :x, :o, :x, :o, nil})) == """
    x o  
      x o
    x o  
    """
  end

  defp winner_by_positions(list, key \\ :x) do
    %Tictac.Board{}
    |> Tictac.Board.put_many(key, list)
    |> Tictac.Board.winner()
  end
end