defmodule Tictac.Game do
  use GenServer

  # TODO: Improve tests
  # TODO: Add monitoring

  @doc """
  Our Game server.
  """

  ## Boot API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  ## Client API

  @doc """
  Adds a player into the game.
  """
  def join(server, pid) when is_pid(pid) do
    GenServer.call(server, {:join, pid})
  end

  def put(server, value, row, col) do
    GenServer.call(server, {:put, value, row, col})
  end

  def players(server) do
    GenServer.call(server, :players)
  end

  ## Server API

  def init([]) do
    state = %{board: %Tictac.Board{}, player1: nil, player2: nil, waiting: :o}
    {:ok, state}
  end

  def handle_call({:join, pid}, _from, state) do
    cond do
      nil?(state.player1) ->
        state = %{state | player1: pid}
        {:reply, {:ok, :x}, state}
      nil?(state.player2) ->
        state = %{state | player2: pid}
        state = next_play(state)
        {:reply, {:ok, :o}, state}
      true ->
        {:reply, :error, state}
    end
  end

  def handle_call({:put, value, row, col}, _from, %{waiting: value} = state) do
    case Tictac.Board.put(state.board, value, row, col) do
      {:ok, board} ->
        cond do
          winner = Tictac.Board.winner(board) ->
            notify_winner(state.player1, winner == :x, board)
            notify_winner(state.player2, winner == :o, board)
          Tictac.Board.full?(board) ->
            notify_draw(state.player1, board)
            notify_draw(state.player2, board)
          true ->
            :ok
        end

        state = next_play(%{state | board: board})
        {:reply, {:ok, board}, state}
      :error ->
        {:reply, :retry, state}
    end
  end

  def handle_call({:put, _value, _row, _col}, _from, state) do
    {:reply, :cheater, state}
  end

  def handle_call(:players, _from, state) do
    {:reply, {state.player1, state.player2}, state}
  end

  ## Helpers

  defp notify_winner(pid, true, board) do
    send pid, {:you_won, board}
  end

  defp notify_winner(pid, false, board) do
    send pid, {:you_lost, board}
  end

  defp notify_draw(pid, board) do
    send pid, {:draw, board}
  end

  defp next_play(%{waiting: :o, player1: player1, board: board} = state) do
    send player1, {:play, board}
    %{state | waiting: :x}
  end

  defp next_play(%{waiting: :x, player2: player2, board: board} = state) do
    send player2, {:play, board}
    %{state | waiting: :o}
  end
end
