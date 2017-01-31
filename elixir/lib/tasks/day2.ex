defmodule Mix.Tasks.Day2 do
  use Mix.Task

  @moduledoc """
  Documentation for Mix.Tasks.Day2.
  """

  def run(_args) do
    IO.puts("Day2 Quiz")
    { :ok, input } = File.read("inputs/day2.txt")
    instruction_lines = String.split(input, "\n")
    instructions = Enum.map(instruction_lines, fn(line) -> to_charlist(line) end)
    instructions = Enum.reject(instructions, fn(line) -> Enum.empty?(line) end)
    codes = access_bathroom(instructions)
    IO.puts("Try those simple numbers:")
    IO.inspect(codes)

    crazy_codes = access_crazy_bathroom(instructions)
    IO.puts("Try those crazy numbers:")
    IO.inspect(crazy_codes)
  end

  @doc """
  Hello world.

  ## Examples

      iex> Mix.Tasks.Day2.access_bathroom([[?D, ?L]])
      [7]

      iex> Mix.Tasks.Day2.access_bathroom([[?D, ?L], [?R, ?R, ?R, ?D, ?D]])
      [7, 9]

      iex> Mix.Tasks.Day2.access_bathroom([[?D, ?L], [?R, ?R, ?R, ?D, ?D], [?U, ?U, ?U, ?L, ?D]])
      [7, 9, 5]

  """
  def access_bathroom(instructions) do
    movements = Enum.map(instructions, fn(charlist) -> Enum.map(charlist, fn(char) -> char_to_movement(char) end) end)
    positions = reduce_positions(movements, [[1, 1]])
    Enum.map(positions, fn(position) -> position_to_keypad_digit(position) end)
  end

  def reduce_positions([ movement | rest ], results) do
    start_position = List.last(results)
    reduce_positions(rest, results ++ [ move_around_keypad(start_position, movement) ])
  end

  def reduce_positions([ ], [ _head | results ]) do
    results
  end

  def access_crazy_bathroom(instructions) do
    movements = Enum.map(instructions, fn(charlist) -> Enum.map(charlist, fn(char) -> char_to_movement(char) end) end)
    positions = reduce_crazy_positions(movements, [[0, 2]])
    Enum.map(positions, fn(position) -> position_to_crazy_keypad_char(position) end)
  end

  def reduce_crazy_positions([ movement | rest ], results) do
    start_position = List.last(results)
    reduce_crazy_positions(rest, results ++ [ move_around_crazy_keypad(start_position, movement) ])
  end

  def reduce_crazy_positions([ ], [ _head | results ]) do
    results
  end

  @doc """
  Moves around a figurative keypad, respecting the physical boundaries,
  returning the final selected digit.

  ## Examples

      iex> Mix.Tasks.Day2.move_around_crazy_keypad([2, 0], [[-1, 0]])
      [2, 0]

      iex> Mix.Tasks.Day2.move_around_crazy_keypad([2, 0], [[1, 0]])
      [2, 0]

      iex> Mix.Tasks.Day2.move_around_crazy_keypad([2, 0], [[0, -1]])
      [2, 0]

      iex> Mix.Tasks.Day2.move_around_crazy_keypad([2, 0], [[0, 1]])
      [2, 1]


  """
  def move_around_crazy_keypad([x, y], [ [x1, y1] | remaining ]) do
    npos = Enum.find([[ x+x1, y+y1 ], [x, y]], fn(pos) -> Enum.member?(valid_positions_on_crazy_keypad(), pos) end)
    move_around_crazy_keypad(npos, remaining)
  end

  def move_around_crazy_keypad([x, y], [ ]) do
    [x, y]
  end

  def valid_positions_on_crazy_keypad do
    [
      [2, 0],
      [1, 1], [2, 1], [3, 1],
      [0, 2], [1, 2], [2, 2], [3, 2], [4, 2],
      [1, 3], [2, 3], [3, 3],
      [2, 4],
    ]
  end

  @doc """
  Moves around a figurative keypad, respecting the physical boundaries,
  returning the final selected digit.

  ## Examples

      iex> Mix.Tasks.Day2.move_around_keypad([1, 1], [[0, 1]])
      [1, 2]

      iex> Mix.Tasks.Day2.move_around_keypad([1, 1], [[0, 10]])
      [1, 2]

      iex> Mix.Tasks.Day2.move_around_keypad([1, 1], [[-10, 0]])
      [0, 1]

      iex> Mix.Tasks.Day2.move_around_keypad([1, 1], [[0, -1], [0, -1], [-1, 0], [-1, 0], [0, 1], [0, 1]])
      [0, 2]

  """
  def move_around_keypad([x, y], [ [x1, y1] | remaining ]) do
    move_around_keypad([ max(min(x+x1, 2), 0), max(min(y+y1, 2), 0) ], remaining)
  end

  def move_around_keypad([x, y], [ ]) do
    [x, y]
  end

  @doc """
  Maps a movement char U D L R to a movement expressed with [x, y]

  ## Examples

      iex> Mix.Tasks.Day2.char_to_movement(?U)
      [0, -1]

      iex> Mix.Tasks.Day2.char_to_movement(?D)
      [0, 1]

      iex> Mix.Tasks.Day2.char_to_movement(?L)
      [-1, 0]

      iex> Mix.Tasks.Day2.char_to_movement(?R)
      [1, 0]

  """
  def char_to_movement(char) do
    case char do
      ?U -> [0, -1]
      ?D -> [0, 1]
      ?R -> [1, 0]
      ?L -> [-1, 0]
    end
  end

  @doc """
  Maps a x/y position to the keypad number.

  ## Examples

      iex> Mix.Tasks.Day2.position_to_keypad_digit([0, 0])
      1

      iex> Mix.Tasks.Day2.position_to_keypad_digit([1, 0])
      2

      iex> Mix.Tasks.Day2.position_to_keypad_digit([2, 0])
      3

      iex> Mix.Tasks.Day2.position_to_keypad_digit([0, 1])
      4

      iex> Mix.Tasks.Day2.position_to_keypad_digit([1, 1])
      5

      iex> Mix.Tasks.Day2.position_to_keypad_digit([2, 1])
      6

      iex> Mix.Tasks.Day2.position_to_keypad_digit([0, 2])
      7

      iex> Mix.Tasks.Day2.position_to_keypad_digit([1, 2])
      8

      iex> Mix.Tasks.Day2.position_to_keypad_digit([2, 2])
      9

  """
  def position_to_keypad_digit([x, y]) do
    case { x, y } do
      { 0, 0 } -> 1
      { 1, 0 } -> 2
      { 2, 0 } -> 3
      { 0, 1 } -> 4
      { 1, 1 } -> 5
      { 2, 1 } -> 6
      { 0, 2 } -> 7
      { 1, 2 } -> 8
      { 2, 2 } -> 9
    end
  end

  @doc """
  Maps a x/y position to the crazy keypad char.

  ## Examples

      iex> Mix.Tasks.Day2.position_to_crazy_keypad_char([2, 0])
      ?1

      iex> Mix.Tasks.Day2.position_to_crazy_keypad_char([1, 1])
      ?2

      iex> Mix.Tasks.Day2.position_to_crazy_keypad_char([2, 1])
      ?3

      iex> Mix.Tasks.Day2.position_to_crazy_keypad_char([3, 1])
      ?4

      iex> Mix.Tasks.Day2.position_to_crazy_keypad_char([0, 2])
      ?5

      iex> Mix.Tasks.Day2.position_to_crazy_keypad_char([1, 2])
      ?6

      iex> Mix.Tasks.Day2.position_to_crazy_keypad_char([2, 2])
      ?7

      iex> Mix.Tasks.Day2.position_to_crazy_keypad_char([3, 2])
      ?8

      iex> Mix.Tasks.Day2.position_to_crazy_keypad_char([4, 2])
      ?9

      iex> Mix.Tasks.Day2.position_to_crazy_keypad_char([1, 3])
      ?A

      iex> Mix.Tasks.Day2.position_to_crazy_keypad_char([2, 3])
      ?B

      iex> Mix.Tasks.Day2.position_to_crazy_keypad_char([3, 3])
      ?C

      iex> Mix.Tasks.Day2.position_to_crazy_keypad_char([2, 4])
      ?D
  """
  def position_to_crazy_keypad_char([x, y]) do
    case { x, y } do
      { 2, 0 } -> ?1
      { 1, 1 } -> ?2
      { 2, 1 } -> ?3
      { 3, 1 } -> ?4
      { 0, 2 } -> ?5
      { 1, 2 } -> ?6
      { 2, 2 } -> ?7
      { 3, 2 } -> ?8
      { 4, 2 } -> ?9
      { 1, 3 } -> ?A
      { 2, 3 } -> ?B
      { 3, 3 } -> ?C
      { 2, 4 } -> ?D
    end
  end

end
