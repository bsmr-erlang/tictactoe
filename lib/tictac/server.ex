defmodule Tictac.Server do
  require Logger

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Game started on port #{port}"
    loop_acceptor(socket, :game_server)
  end

  defp loop_acceptor(socket, game) do
    {:ok, client} = :gen_tcp.accept(socket)
    Task.Supervisor.start_child(:players_supervisor, fn -> start_game(client, game) end)
    loop_acceptor(socket, game)
  end

  defp start_game(socket, game) do
    case Tictac.Game.join(game, self()) do
      {:ok, piece} ->
        write_line(socket, "Waiting for other player...")
        wait_game(socket, game, piece)
      :error ->
        write_line(socket, "Game is full.")
        :gen_tcp.close(socket)
    end
  end

  defp wait_game(socket, game, piece) do
    receive do
      {:play, board} ->
        write_line(socket, "#{piece}, it is your turn to play.")
        write_line(socket, to_string(board))
        play_game(socket, game, piece)
      {:you_won, board} ->
        write_line(socket, "#{piece}, you won!")
        write_line(socket, to_string(board))
        :gen_tcp.close(socket)
      {:you_lost, board} ->
        write_line(socket, "#{piece}, you lost!")
        write_line(socket, to_string(board))
        :gen_tcp.close(socket)
      {:draw, board} ->
        write_line(socket, "\x{1f638} 's")
        write_line(socket, to_string(board))
        :gen_tcp.close(socket)
    end
  end

  defp play_game(socket, game, piece) do
    case read_line(socket) do
      {:ok, <<"PUT ", row, " ", col>>} when row in ?0..?2 and col in ?0..?2 ->
        case Tictac.Game.put(game, piece, row - ?0, col - ?0) do
          {:ok, _board} ->
            write_line(socket, "Good move!")
            wait_game(socket, game, piece)
          :retry ->
            write_line(socket, "Position already taken. Try again.")
            play_game(socket, game, piece)
        end

      {:ok, _} ->
        write_line(socket, "Wrong command. Try again.")
        play_game(socket, game, piece)

      {:error, _} ->
        :gen_tcp.close(socket)
        :ok
    end
  end

  defp read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> {:ok, String.strip(data)}
      {:error, _} = error -> error
    end
  end

  defp write_line(socket, line) do
    :gen_tcp.send(socket, line <> "\n")
  end
end