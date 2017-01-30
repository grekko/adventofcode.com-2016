# Day 1: No Time for a Taxicab
# http://adventofcode.com/2016/day/1
#
# 1st Riddle:
# The task is to calculate the so called Manhattan distance[1] for
# a given set of movement instructions. The instructions are in the
# format of "Rn" or "Ln" where n is a positive Integer and "R" or "L"
# stand for a 90-degree turn either to the left or right.
#
# [1]: https://en.wikipedia.org/wiki/Taxicab_geometry

defmodule Day1 do
  use Application

  def start(_type, _args) do
    run
  end

  # entry-point
  # 1. Reads given input file, returns BitString <<82, 42, …>>
  # 2. Splits BitString into List of BitStrings ["R1", "L1", …]
  # 3. Delegates to walk with initial position and orientation
  def run do
    { :ok, input } = File.read("input.txt")
    movements = String.split(input, ", ")
    walklog = start_walking(movements)

    [ x, y ] = List.last(walklog)
    [ hq_x, hq_y ] = detect_hq(walklog)

    walked_distance = manhattan_distance(x, y)
    hq_distance = manhattan_distance(hq_x, hq_y)

    IO.puts("---------------------------------")
    IO.puts("Arrived at [#{x}, #{y}]. Manhattan distance: #{walked_distance}.")
    IO.puts("The actual hq is at [#{hq_x}, #{hq_y}], distance: #{hq_distance}")
    IO.puts("---------------------------------")
  end

  @doc ~S"""
  Executes the given movements and returns a walklog containing a list of
  positions with x/y-coordinates representing the walked path.

  ## Examples

      iex> Day1.start_walking(["R1", "R1", "R1", "R1"])
      [[0, 0], [1, 0], [1, 1], [0, 1], [0, 0]]

      iex> Day1.start_walking(["R2", "L1", "L2", "L1"])
      [[0, 0], [1, 0], [2, 0], [2, -1], [1, -1], [0, -1], [0, 0]]

  """
  def start_walking(movements) do
    walk([ movements, [ 0, 0, :north ], [[0, 0]]])
  end

  @doc ~S"""
  Calculates the manhattan distance for a given x and y relative to
  an origin at [0, 0].

  ## Examples

      iex> Day1.manhattan_distance(1, 1)
      2

      iex> Day1.manhattan_distance(14, -4)
      18

  """
  def manhattan_distance(x, y) do
    :erlang.abs(x) + :erlang.abs(y)
  end

  @doc ~S"""
  Calculates the positions for a given movement between to coordinates.

  ## Examples

      iex> Day1.steps(0, 0, 1, 0)
      [[1, 0]]

      iex> Day1.steps(0, 0, 3, 0)
      [[1, 0], [2, 0], [3, 0]]

      iex> Day1.steps(0, 0, 0, -3)
      [[0, -1], [0, -2], [0, -3]]

      iex> Day1.steps(-14, 44, -14, 41)
      [[-14, 43], [-14, 42], [-14, 41]]

  """
  def steps(x1, y1, x2, y1) do
    without_head Enum.map(Enum.to_list(x1..x2), fn(x) -> [x, y1] end)
  end

  def steps(x1, y1, x1, y2) do
    without_head Enum.map(Enum.to_list(y1..y2), fn(y) -> [x1, y] end)
  end

  @doc ~S"""
  Detects the first position in the walklog that has been visited twice.

  ## Examples

      iex> Day1.detect_hq([[0, 0], [1, 0], [2, 0], [2, 1], [1, 1], [1, 0], [1, -1], [0, -1], [0, 0]])
      [1, 0]

  """
  def detect_hq(walklog) do
    detect_first_duplicate(walklog, 0, [])
  end

  defp detect_first_duplicate([ position | walklog ], index, duplicates) do
    if Enum.member?(walklog, position) do
      distance = Enum.find_index(walklog, fn(x) -> x == position end)
      detect_first_duplicate(walklog, index + 1, duplicates ++ [[ index + distance, position ]])
    else
      detect_first_duplicate(walklog, index + 1, duplicates)
    end
  end

  defp detect_first_duplicate([], _index, duplicates) do
    Enum.at(Enum.at(Enum.sort(duplicates), 0), 1)
  end


  defp without_head(list) do
    List.delete_at(list, 0)
  end

  defp walk([[], [ _x, _y, _orientation ], walklog]) do
    walklog
  end

  # processing the movements
  # 1. Fetch the next movement from the head of the list
  # 2. Extract the rotation and distance (steps to move)
  # 3. Calculate new_orientation and apply distance to calculate new position
  # 4. Call the same method with the new_orientation, updated position and tail of movements
  defp walk([[ movement | tail ], [ x, y, orientation ], walklog]) do
    <<rotate_to::8, distance_binary::binary>> = movement
    # :string.to_integer is an Erlang function that translates a char list (List of codepoints)
    # to the integer it represents. The second return value is a rest in case of a decimal value, e.g. "0.5"
    # Other examples:
    # :string.to_integer('3.1415')
    # {3, '.1415'}
    # :string.to_integer('-35')
    # {-35, []}
    { distance, _ } = :string.to_integer(to_char_list(distance_binary))
    new_orientation = navigate(orientation, rotate_to)
    { x1, y1 } = move(new_orientation, x, y, distance)
    walk([tail, [ x1, y1, new_orientation ], walklog ++ steps(x, y, x1, y1) ])
  end

  defp move(orientation, x, y, distance) do
    case orientation do
      :north -> { x, y - distance }
      :east  -> { x + distance, y }
      :south -> { x, y + distance }
      :west  -> { x - distance, y }
    end
  end

  defp navigate(orientation, rotate_to) do
    case { orientation, rotate_to } do
      { :north, ?R } -> :east
      { :north, ?L } -> :west
      { :east,  ?R } -> :south
      { :east,  ?L } -> :north
      { :south, ?R } -> :west
      { :south, ?L } -> :east
      { :west,  ?R } -> :north
      { :west,  ?L } -> :south
    end
  end
end
