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
    IO.inspect(instructions)
  end

  @doc """
  Hello world.

  ## Examples

      iex> Mix.Tasks.Day2.access_bathroom(["U", "L", "L"])
      :world

  """
  def access_bathroom(_instructions) do
    # 1. Start with a position
    # 2. Transform all moves to positional changes
    # 3. Gather final digits for each line of positional changes
    #    Using the last digit of the previous line as a starter for the next
    :world
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

      iex> Mix.Tasks.Day2.char_to_movement('U')
      [0, -1]

  """
  def char_to_movement(char) do
    [0, -1]
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

end
