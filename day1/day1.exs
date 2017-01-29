# [ ['R', '2', 'R', '2', … '\m'], [x, y] ]
require IEx;

defmodule ElfHQ do
  def run do
    { :ok, input } = File.read("input.txt")
    movements = String.split(input, ", ")
    walk(movements)
  end

  def walk([[], [ x, y, orientation ]]) do
    IO.puts "You arrived at: #{x}, #{y} looking towards #{orientation}. So the distance is #{x+y}"
  end

  def walk([[ movement | tail ], [ x, y, orientation ]]) do
    IO.inspect(movement)
    <<rotate_to::8, distance_binary::binary>> = movement
    { distance, _ } = :string.to_integer(to_char_list(distance_binary))
    # IEx.pry
    new_orientation = navigate(orientation, rotate_to)
    { x1, y1 } = move(new_orientation, x, y, distance)
    IO.puts("Looking #{orientation}, turning #{new_orientation}. Going by #{distance}")
    IO.puts("Moving from #{x},#{y} to #{x1}, #{y1}")
    walk([tail, [ x1, y1, new_orientation ]])
  end

  def walk(movements) do
    # walk([ movements ], [ 0, 0, :north ])
    walk([ movements, [ 0, 0, :north ]])
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
