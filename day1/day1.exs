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

require IEx;
# Required to enable usage of `IEx.pry` for debugging.

defmodule ElfHQ do
  # entry-point
  # 1. Reads given input file, returns BitString <<82, 42, …>>
  # 2. Splits BitString into List of BitStrings ["R1", "L1", …]
  # 3. Delegates to walk with initial position and orientation
  def run do
    { :ok, input } = File.read("input.txt")
    movements = String.split(input, ", ")
    walk([ movements, [ 0, 0, :north ], []])
  end

  # final step
  # Thw movements list is empty, so we reached our target.
  def walk([[], [ x, y, orientation ], walklog]) do
    [ hq_x, hq_y ] = detect_hq(walklog)
    manhattan_distance = :erlang.abs(x) + :erlang.abs(y)
    actual_hq_distance = :erlang.abs(hq_x) + :erlang.abs(hq_y)
    IO.puts("---------------------------------")
    IO.puts("Arrived at [#{x}, #{y}], looking at #{orientation}, distance: #{manhattan_distance}.")
    IO.puts("The actual hq is at [#{hq_x}, #{hq_y}], distance: #{actual_hq_distance}")
    IO.puts("---------------------------------")
  end

  # processing the movements
  # 1. Fetch the next movement from the head of the list
  # 2. Extract the rotation and distance (steps to move)
  # 3. Calculate new_orientation and apply distance to calculate new position
  # 4. Call the same method with the new_orientation, updated position and tail of movements
  def walk([[ movement | tail ], [ x, y, orientation ], walklog]) do
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
    IO.puts("Turning #{orientation} -> #{new_orientation}. Taking #{distance} step(s) from [#{x}, #{y}] to [#{x1}, #{y1}]")
    walk([tail, [ x1, y1, new_orientation ], walklog ++ [[ x, y ]]])
  end

  # Detects the first position in the walklog that has been visited twice.
  defp detect_hq(walklog) do
    duplicate_positions = detect_duplicates(walklog, 0, [])
    # TODO: think more clearly about the problen ;)
    IO.inspect(duplicate_positions)
    [ 0, 0 ]
  end

  defp detect_duplicates([ position | walklog ], index, duplicates) do
    if Enum.member?(walklog, position) do
      distance = Enum.find_index(walklog, fn(x) -> x == position end)
      detect_duplicates(walklog, index + 1, duplicates ++ [ index, distance, index + distance, position ])
    else
      detect_duplicates(walklog, index + 1, duplicates)
    end
  end

  defp detect_duplicates([], index, duplicates) do
    duplicates
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

ElfHQ.run
