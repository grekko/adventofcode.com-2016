# --- Day 8: Two-Factor Authentication ---
#
# You come across a door implementing what you can only assume is a
# two-factor authentication after a long game of requirements telephone.
#
# To get past the door, you first swipe a keycard (no problem; there was one on
# a nearby desk). Then, it displays a code on a little screen, and you type
# that code on a keypad. Then, presumably, the door unlocks.
#
# Unfortunately, the screen has been smashed. After a few minutes, you've taken
# everything apart and figured out how it works. Now you just have to work out
# what the screen would have displayed.
#
# The magnetic strip on the card you swiped encodes a series of instructions
# for the screen; these instructions are your puzzle input. The screen is 50
# pixels wide and 6 pixels tall, all of which start off, and is capable of
# three somewhat peculiar operations:
#
# rect AxB
# turns on all of the pixels in a rectangle at the top-left of the screen which
# is A wide and B tall.
#
# rotate row y=A by B
# shifts all of the pixels in row A (0 is the top row) right by B pixels.
# Pixels that would fall off the right end appear at the left end of the row.
#
# rotate column x=A by B
# shifts all of the pixels in column A (0 is the left column) down by B pixels.
# Pixels that would fall off the bottom appear at the top of the column. For
# example, here is a simple sequence on a smaller screen:
#
# rect 3x2
# creates a small rectangle in the top-left corner:
#
# ###....
# ###....
# .......
#
# rotate column x=1 by 1
# rotates the second column down by one pixel:
#
# #.#....
# ###....
# .#.....
#
# rotate row y=0 by 4
# rotates the top row right by four pixels:
#
# ....#.#
# ###....
# .#.....
#
# rotate column x=1 by 1
# again rotates the second column down by one pixel, causing the bottom pixel
# to wrap back to the top:
#
# .#..#.#
# #.#....
# .#.....
#
# As you can see, this display technology is extremely powerful, and will soon
# dominate the tiny-code-displaying-screen market. That's what the
# advertisement on the back of the display tries to convince you, anyway.
#
# There seems to be an intermediate check of the voltage used by the display:
# after you swipe your card, if the screen did work, how many pixels should be
# lit?
#
defmodule Mix.Tasks.Day8 do
  use Mix.Task

  def run(_args) do
    { :ok, input } = File.read("inputs/day8.txt")

    lights = input
      |> String.split("\n")
      |> Enum.drop(-1)
      |> apply_instructions
      |> print

    IO.puts("---------------------------------")
    IO.inspect(Enum.count(lights))
    IO.puts("---------------------------------")
  end

  def print(map) do
    Enum.each((0..5), fn(y) ->
      Enum.each((0..49), fn(x) ->
        if Map.get(map, { x, y }, 0) == 1, do: IO.write("#"), else: IO.write("-")
      end)
        IO.write("\n\r")
    end)
    IO.write("\n\r")
    map
  end

  @doc """
  It applies the given instructions.

  ## Examples

      iex> Mix.Tasks.Day8.apply_instructions(["rect 3x2", "rotate column x=1 by 1"])
      %{ {0, 0} => 1, {0, 1} => 1, {1, 1} => 1, {1, 2} => 1, {2, 0} => 1, {2, 1} => 1}

  """
  def apply_instructions(instructions) do
    apply_instructions(instructions, %{})
  end

  defp apply_instructions([], map), do: map

  defp apply_instructions([ head | tail ], map) do
    apply_instructions(tail, apply_instruction(head, map))
  end

  defp apply_instruction("rect " <> operation, map) do
    [x, y] = Regex.scan(~r/(\d+)x(\d+)/, operation, capture: :all_but_first)
      |> List.flatten
      |> Enum.map(&String.to_integer/1)
    apply_rect(map, x, y)
  end

  defp apply_instruction("rotate row y=" <> operation, map) do
    [row, offset] = Regex.scan(~r/(\d+) by (\d+)/, operation, capture: :all_but_first)
      |> List.flatten
      |> Enum.map(&String.to_integer/1)
    apply_rotate_row(map, row, offset)
  end

  defp apply_instruction("rotate column x=" <> operation, map) do
    [col, offset] = Regex.scan(~r/(\d+) by (\d+)/, operation, capture: :all_but_first)
      |> List.flatten
      |> Enum.map(&String.to_integer/1)
    apply_rotate_column(map, col, offset)
  end

  @doc """
  Creates rect of active lights with the given size.

  ## Examples

      iex> Mix.Tasks.Day8.apply_rect(%{}, 1, 1)
      %{ {0, 0} => 1 }

      iex> Mix.Tasks.Day8.apply_rect(%{ {0, 0} => 1}, 1, 1)
      %{ {0, 0} => 1 }

      iex> Mix.Tasks.Day8.apply_rect(%{}, 2, 2)
      %{ {0, 0} => 1, { 0, 1 } => 1,  { 1, 0 } => 1, { 1, 1 } => 1 }

  """
  def apply_rect(map, x, y) do
    rect = for xStep <- 0..(x-1), yStep <- 0..(y-1), into: %{}, do: {{ xStep, yStep }, 1}
    Map.merge(map, rect)
  end

  @doc """
  Rotates all active lamps with a given column (or x-position) by offset.
  The display is 6 pixels tall (currently just hardcode) and rotating may
  push pixels over the "edge".

  ## Examples

      iex> Mix.Tasks.Day8.apply_rotate_column(%{ {0, 0} => 1}, 0, 1)
      %{ {0, 1} => 1 }

      iex> Mix.Tasks.Day8.apply_rotate_column(%{ {0, 0} => 1}, 1, 1)
      %{ {0, 0} => 1 }

      iex> Mix.Tasks.Day8.apply_rotate_column(%{ {0, 0} => 1}, 0, 5)
      %{ {0, 5} => 1 }

      iex> Mix.Tasks.Day8.apply_rotate_column(%{ {0, 0} => 1}, 0, 6)
      %{ {0, 0} => 1 }

      iex> Mix.Tasks.Day8.apply_rotate_column(%{ {0, 0} => 1}, 0, -1)
      %{ {0, 5} => 1 }

      iex> Mix.Tasks.Day8.apply_rotate_column(%{ {0, 0} => 1, {1, 0} => 1, {2, 0} => 1}, 0, 5)
      %{ {0, 5} => 1, {1, 0} => 1, {2, 0} => 1}


  """
  def apply_rotate_column(map, col, offset) do
    Enum.into(Enum.map(map, fn({{ x, y }, v}) ->
      if x == col do
        adjustedOffset = rem(offset, 6)
        offsetAmount = rem(adjustedOffset + 6, 6)
        newY = y + offsetAmount
        adjustedNewY = rem(newY, 6)
        {{ x, adjustedNewY}, v}
      else
        {{ x, y }, v}
      end
    end), %{})
  end

  @doc """
  Rotates all active lamps with a given row (or x-position) by offset.
  The display is 50 pixels wide (currently just hardcode) and rotating may
  push pixels over the "edge".

  ## Examples

      iex> Mix.Tasks.Day8.apply_rotate_row(%{ {0, 0} => 1}, 0, 1)
      %{ {1, 0} => 1 }

      iex> Mix.Tasks.Day8.apply_rotate_row(%{ {0, 0} => 1}, 0, 49)
      %{ {49, 0} => 1 }

      iex> Mix.Tasks.Day8.apply_rotate_row(%{ {1, 1} => 1, {0, 0} => 1}, 1, 1)
      %{ {2, 1} => 1, {0, 0} => 1 }

  """
  def apply_rotate_row(map, row, offset) do
    Enum.into(Enum.map(map, fn({{ x, y }, v}) ->
      if y == row do
        adjustedOffset = rem(offset, 50)
        offsetAmount = rem(adjustedOffset + 50, 50)
        newX = x + offsetAmount
        adjustedNewX = rem(newX, 50)
        {{ adjustedNewX, y}, v}
      else
        {{ x, y }, v}
      end
    end), %{})
  end

end

