# --- Day 2: Bathroom Security ---
#
# You arrive at Easter Bunny Headquarters under cover of darkness. However, you left in such a rush that you forgot to use the bathroom! Fancy office buildings like this one usually have keypad locks on their bathrooms, so you search the front desk for the code.
#
# "In order to improve security," the document you find says, "bathroom codes will no longer be written down. Instead, please memorize and follow the procedure below to access the bathrooms."
#
# The document goes on to explain that each button to be pressed can be found by starting on the previous button and moving to adjacent buttons on the keypad: U moves up, D moves down, L moves left, and R moves right. Each line of instructions corresponds to one button, starting at the previous button (or, for the first line, the "5" button); press whatever button you're on at the end of each line. If a move doesn't lead to a button, ignore it.
#
# You can't hold it much longer, so you decide to figure out the code as you walk to the bathroom. You picture a keypad like this:
#
# 1 2 3
# 4 5 6
# 7 8 9
# Suppose your instructions are:
#
# ULL
# RRDDD
# LURDL
# UUUUD
# You start at "5" and move up (to "2"), left (to "1"), and left (you can't, and stay on "1"), so the first button is 1.
# Starting from the previous button ("1"), you move right twice (to "3") and then down three times (stopping at "9" after two moves and ignoring the third), ending up with 9.
# Continuing from "9", you move left, up, right, down, and left, ending with 8.
# Finally, you move up four times (stopping at "2"), then down once, ending with 5.
# So, in this example, the bathroom code is 1985.
#
# Your puzzle input is the instructions from the document you found at the front desk. What is the bathroom code?
#
# Your puzzle answer was 14894.
#
# --- Part Two ---
#
# You finally arrive at the bathroom (it's a several minute walk from the lobby so visitors can behold the many fancy conference rooms and water coolers on this floor) and go to punch in the code. Much to your bladder's dismay, the keypad is not at all like you imagined it. Instead, you are confronted with the result of hundreds of man-hours of bathroom-keypad-design meetings:
#
#     1
#   2 3 4
# 5 6 7 8 9
#   A B C
#     D
# You still start at "5" and stop when you're at an edge, but given the same instructions as above, the outcome is very different:
#
# You start at "5" and don't move at all (up and left are both edges), ending at 5.
# Continuing from "5", you move right twice and down three times (through "6", "7", "B", "D", "D"), ending at D.
# Then, from "D", you move five more times (through "D", "B", "C", "C", "B"), ending at B.
# Finally, after five more moves, you end at 3.
# So, given the actual keypad layout, the code would be 5DB3.
#
# Using the same instructions in your puzzle input, what is the correct bathroom code?
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
