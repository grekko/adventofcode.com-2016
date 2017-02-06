# --- Day 3: Squares With Three Sides ---
#
# Now that you can think clearly, you move deeper into the labyrinth of hallways and office furniture that makes up this part of Easter Bunny HQ. This must be a graphic design department; the walls are covered in specifications for triangles.
#
# Or are they?
#
# The design document gives the side lengths of each triangle it describes, but... 5 10 25? Some of these aren't triangles. You can't help but mark the impossible ones.
#
# In a valid triangle, the sum of any two sides must be larger than the remaining side. For example, the "triangle" given above is impossible, because 5 + 10 is not larger than 25.
#
# In your puzzle input, how many of the listed triangles are possible?
#
# --- Part Two ---
#
# Now that you've helpfully marked up their design documents, it occurs to you that triangles are specified in groups of three vertically. Each set of three numbers in a column specifies a triangle. Rows are unrelated.
#
# For example, given the following specification, numbers with the same hundreds digit would be part of the same triangle:
#
# 101 301 501
# 102 302 502
# 103 303 503
# 201 401 601
# 202 402 602
# 203 403 603
# In your puzzle input, and instead reading by columns, how many of the listed triangles are possible?
defmodule Mix.Tasks.Day3 do
  use Mix.Task

  def run(_args) do
    { :ok, input } = File.read("inputs/day3.txt")
    triangle_lines = String.split(input, "\n")
    maybe_triangles = Enum.map(triangle_lines, fn(x) -> parse_triangle(x) end)
    vertical_triangles = generate_vertical_triangles(maybe_triangles)
    real_triangles = reject_invalid_triangles(maybe_triangles)
    real_vertical_triangles = reject_invalid_triangles(vertical_triangles)

    IO.puts("---------------------------------")
    IO.puts("Count: #{length(real_triangles)}")
    IO.puts("Vertical: #{length(real_vertical_triangles)}")
    IO.puts("---------------------------------")
  end

  @doc """
  Transforms horizontal triangles to vertical triangles.

  ## Examples

      iex> Mix.Tasks.Day3.generate_vertical_triangles([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
      [[1, 4, 7], [2, 5, 8], [3, 6, 9]]

  """
  def generate_vertical_triangles(triangles) do
    pair_vertical_triangles(List.flatten(triangles), [])
  end

  defp pair_vertical_triangles([a, b, c, d, e, f, g, h, i | rest], results) do
    pair_vertical_triangles(rest, results ++ [[a, d, g], [b, e, h], [c, f, i]])
  end

  defp pair_vertical_triangles([], results) do
    results
  end

  @doc """
  Extracts triangle from string

  ## Examples

      iex> Mix.Tasks.Day3.parse_triangle("  541  588  421")
      [541, 588, 421]

      iex> Mix.Tasks.Day3.parse_triangle("  530  616  422")
      [530, 616, 422]

  """
  def parse_triangle(string) do
    Enum.map(String.split(string), fn(x) -> :erlang.binary_to_integer(x) end)
  end

  @doc """
  Rejects lists of invalid triangle lengths.
  In a valid triangle, the sum of any two sides must be larger than the
  remaining side. For example [5, 10, 25] is impossible,
  because 5 + 10 is not larger than 25.

  ## Examples

      iex> Mix.Tasks.Day3.reject_invalid_triangles([[5, 10, 25]])
      []

      iex> Mix.Tasks.Day3.reject_invalid_triangles([[5, 10, 25], [2, 3, 4]])
      [[2, 3, 4]]

  """
  def reject_invalid_triangles(triangles) do
    Enum.filter(triangles, fn(maybe_triangle) -> validate_triangle(maybe_triangle) end)
  end

  defp validate_triangle([x, y, z]) do
     x + y > z and x + z > y and y + z > x
  end

  defp validate_triangle([]) do
    false
  end
end

