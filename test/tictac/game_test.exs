defmodule Tictac.GameTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, game} = Tictac.Game.start_link()
    {:ok, game: game}
  end

  test "player1 joins the game", %{game: game} do
    assert Tictac.Game.join(game, self()) == {:ok, :x}
    assert Tictac.Game.players(game) == {self(), nil}
  end

  test "player2 joins the game", %{game: game} do
    assert Tictac.Game.join(game, self()) == {:ok, :x}
    assert Tictac.Game.join(game, self()) == {:ok, :o}
    assert Tictac.Game.players(game) == {self(), self()}
  end

  test "player3 does not join the game", %{game: game} do
    Tictac.Game.join(game, self())
    Tictac.Game.join(game, self())
    assert Tictac.Game.join(game, self()) == :error
  end
end
