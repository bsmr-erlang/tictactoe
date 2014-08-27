defmodule Tictac.Board do
  @moduledoc """
  Our tic tac toe board.
  """

  defstruct data: {nil, nil, nil,
                   nil, nil, nil,
                   nil, nil, nil}

  @values [:x, :o]

  @doc """
  Initializes a new board with tuple.
  """
  def new(tuple) when tuple_size(tuple) == 9 do
    %Tictac.Board{data: tuple}
  end

  @doc """
  Stores `x` or `o` at the given position.

  ## Examples

      iex> board = %Tictac.Board{}
      iex> {:ok, board} = Tictac.Board.put(board, :x, 1, 2)
      iex> Tictac.Board.get(board, 1, 2)
      :x

      iex> board = %Tictac.Board{}
      iex> {:ok, board} = Tictac.Board.put(board, :x, 1, 2)
      iex> Tictac.Board.put(board, :x, 1, 2)
      :error

  """
  def put(board, value, row, col) when value in @values do
    pos = row_and_col_to_pos(row, col)
    case elem(board.data, pos) do
      nil ->
        data = put_elem(board.data, pos, value)
        {:ok, %Tictac.Board{data: data}}
      _ ->
        :error
    end
  end

  @doc """
  Puts many values in the board at once.

  This function is strict as it expects the value
  to not be set before.

  ## Examples

      iex> board = %Tictac.Board{}
      iex> board = Tictac.Board.put_many(board, :x, [{1, 2}, {0, 0}])
      iex> Tictac.Board.get(board, 1, 2)
      :x
      iex> Tictac.Board.get(board, 0, 0)
      :x
      iex> Tictac.Board.get(board, 1, 1)
      nil

  """
  def put_many(board, value, list) when value in @values do
    Enum.reduce list, board, fn {row, col}, acc ->
      {:ok, acc} = put(acc, value, row, col)
      acc
    end
  end

  @doc """
  Gets a value from the board.
  """
  def get(board, row, col) do
    pos = row_and_col_to_pos(row, col)
    elem(board.data, pos)
  end

  defp row_and_col_to_pos(row, col) do
    row * 3 + col
  end

  @doc """
  Returns the winner for this board if there is one.

  ## Examples

      iex> board = Tictac.Board.new({nil, :x, nil,
      ...>                           nil, :x, nil,
      ...>                           nil, :x, nil})
      iex> Tictac.Board.winner(board)
      :x

  """
  def winner(%Tictac.Board{data: data}) do
    data_winner(data)
  end

  @doc """
  Checks if the board is full.

  ## Examples

      iex> board = %Tictac.Board{}
      iex> Tictac.Board.full?(board)
      false

      iex> board = Tictac.Board.new({:x, :x, :x, :x, nil, :o, :o, :o, :o})
      iex> Tictac.Board.full?(board)
      false

      iex> board = Tictac.Board.new({:x, :x, :x, :x, :o, :o, :o, :o, :o})
      iex> Tictac.Board.full?(board)
      true

  """
  def full?(%Tictac.Board{data: data}) do
    Enum.all? 1..9, fn i -> elem(data, i - 1) in @values end
  end

  @doc """
  Prints a board as a string.
  """
  def to_string(%Tictac.Board{data: data}) do
    {v1, v2, v3, v4, v5, v6, v7, v8, v9} = data
    """
    #{p v1} #{p v2} #{p v3}
    #{p v4} #{p v5} #{p v6}
    #{p v7} #{p v8} #{p v9}
    """
  end

  defp p(nil), do: " "
  defp p(:x),  do: "x"
  defp p(:o),  do: "o"

  defp data_winner({v, v, v,
                    _, _, _,
                    _, _, _}) when v in @values, do: v

  defp data_winner({_, _, _,
                    v, v, v,
                    _, _, _}) when v in @values, do: v

  defp data_winner({_, _, _,
                    _, _, _,
                    v, v, v}) when v in @values, do: v

  defp data_winner({v, _, _,
                    _, v, _,
                    _, _, v}) when v in @values, do: v

  defp data_winner({_, _, v,
                    _, v, _,
                    v, _, _}) when v in @values, do: v

  defp data_winner({v, _, _,
                    v, _, _,
                    v, _, _}) when v in @values, do: v

  defp data_winner({_, v, _,
                    _, v, _,
                    _, v, _}) when v in @values, do: v

  defp data_winner({_, _, v,
                    _, _, v,
                    _, _, v}) when v in @values, do: v

  defp data_winner({_, _, _,
                    _, _, _,
                    _, _, _}), do: nil
end

defimpl Inspect, for: Tictac.Board do
  def inspect(board, _opts) do
    "#Tictac.Board<\n" <> Tictac.Board.to_string(board) <> "\n>"
  end
end

defimpl String.Chars, for: Tictac.Board do
  def to_string(board) do
    Tictac.Board.to_string(board)
  end
end
