# --- Day 9: Explosives in Cyberspace ---
#
# Wandering around a secure area, you come across a datalink port to a new part
# of the network. After briefly scanning it for interesting files, you find one
# file in particular that catches your attention. It's compressed with an
# experimental format, but fortunately, the documentation for the format is
# nearby.
#
# The format compresses a sequence of characters. Whitespace is ignored. To
# indicate that some sequence should be repeated, a marker is added to the
# file, like (10x2). To decompress this marker, take the subsequent 10
# characters and repeat them 2 times. Then, continue reading the file after the
# repeated data. The marker itself is not included in the decompressed output.
#
# If parentheses or other characters appear within the data referenced by a
# marker, that's okay - treat it like normal data, not a marker, and then
# resume looking for markers after the decompressed section.
#
# For example:
#
# ADVENT contains no markers and decompresses to itself with no changes,
# resulting in a decompressed length of 6.
#
# A(1x5)BC repeats only the B a total of 5 times, becoming ABBBBBC for a
# decompressed length of 7.
#
# (3x3)XYZ becomes XYZXYZXYZ for a decompressed length of 9.
#
# A(2x2)BCD(2x2)EFG doubles the BC and EF, becoming ABCBCDEFEFG for a
# decompressed length of 11.
#
# (6x1)(1x3)A simply becomes (1x3)A - the (1x3) looks like a marker, but
# because it's within a data section of another marker, it is not treated any
# differently from the A that comes after it. It has a decompressed length of
# 6.
#
# X(8x2)(3x3)ABCY becomes X(3x3)ABC(3x3)ABCY (for a decompressed length of 18),
# because the decompressed data from the (8x2) marker (the (3x3)ABC) is skipped
# and not processed further.
#
# What is the decompressed length of the file (your puzzle input)?
# Don't count whitespace.
#

# "X12 (3x2)  Ab4(1x1)"
# "X12(3x2)Ab4(1x1)"
# "X12(3x2)Ab4(1x1)" => "X12" "(3x2)" "Ab4(1x1)"

# 1. Remove whitespace from string
defmodule Mix.Tasks.Day9 do
  use Mix.Task

  @marker_regex ~r/(.+)?\((\d+x\d+)\)(.+)?$/U

  def run(_args) do
    { :ok, input } = File.read("inputs/day9.txt")
    clean_input = input
      |> String.split("\n")
      |> Enum.drop(-1)
      |> List.first

    # decompressed = clean_input |> decompress
    # decompressed_length = decompressed |> String.length
    dedecompressed_length = clean_input |> deep_decompress_length

    IO.puts("---------------------------------")
    # IO.puts("Length: #{decompressed_length}")
    IO.puts("Deep de-compressed Length: #{dedecompressed_length}")
    IO.puts("---------------------------------")
  end

  @doc """
  Get deep decompress length.

  ## Examples

      iex> Mix.Tasks.Day9.deep_decompress_length("X(8x2)(3x3)ABCY")
      20

      iex> Mix.Tasks.Day9.deep_decompress_length("(27x12)(20x12)(13x14)(7x10)(1x12)A")
      241920

      iex> Mix.Tasks.Day9.deep_decompress_length("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN")
      445

  """
  def deep_decompress_length(""), do: 0
  def deep_decompress_length(string) do
    %{ result: result, length: length, times: times, rest: rest } = extract_marker(string)
    %{ rest: rest, result: result } = apply_marker(%{ result: result, length: length, times: times, rest: rest })
    decompressed_length = case Regex.match?(@marker_regex, result) do
      true  -> result |> deep_decompress_length
      false -> result |> String.length
    end
    decompressed_length + deep_decompress_length(rest)
  end

  @doc """
  Deep decompress.

  ## Examples

      iex> Mix.Tasks.Day9.deep_decompress("X(8x2)(3x3)ABCY")
      "XABCABCABCABCABCABCY"

  """
  def deep_decompress(""), do: ""
  def deep_decompress(string) do
    %{ result: result, length: length, times: times, rest: rest } = extract_marker(string)
    %{ rest: rest, result: result } = apply_marker(%{ result: result, length: length, times: times, rest: rest })
    nresult = case Regex.match?(@marker_regex, result) do
      true  -> result |> deep_decompress
      false -> result
    end
    nresult <> deep_decompress(rest)
  end

  @doc """
  Processes a compressed string and returns the decompressed version.

  ## Examples

      iex> Mix.Tasks.Day9.decompress("A(1x5)BC")
      "ABBBBBC"

      iex> Mix.Tasks.Day9.decompress("(3x3)XYZ")
      "XYZXYZXYZ"

      iex> Mix.Tasks.Day9.decompress("A(2x2)BCD(2x2)EFG")
      "ABCBCDEFEFG"

      iex> Mix.Tasks.Day9.decompress("(6x1)(1x3)A")
      "(1x3)A"

      iex> Mix.Tasks.Day9.decompress("X(8x2)(3x3)ABCY")
      "X(3x3)ABC(3x3)ABCY"

      iex> Mix.Tasks.Day9.decompress("X(10x1)1234567890")
      "X1234567890"

      iex> Mix.Tasks.Day9.decompress("X(1x10)1")
      "X1111111111"

  """
  def decompress(""), do: ""
  def decompress(string) do
    %{ result: result, length: length, times: times, rest: rest } = extract_marker(string)
    %{ rest: rest, result: result } = apply_marker(%{ result: result, length: length, times: times, rest: rest })
    result <> decompress(rest)
  end

  @doc """
  Extracts the main three components of the currently given string.

  ## Examples

      iex> Mix.Tasks.Day9.extract_marker("X12(3x2)Ab4(1x1)123")
      %{ result: "X12", length: 3, times: 2, rest: "Ab4(1x1)123" }

      iex> Mix.Tasks.Day9.extract_marker("(3x2)Ab4(1x1)123")
      %{ result: "", length: 3, times: 2, rest: "Ab4(1x1)123" }

      iex> Mix.Tasks.Day9.extract_marker("(11x22)Ab4(1x1)123")
      %{ result: "", length: 11, times: 22, rest: "Ab4(1x1)123" }

      iex> Mix.Tasks.Day9.extract_marker("A")
      %{ result: "A", length: 0, times: 0, rest: "" }

  """
  def extract_marker(string) do
    match = Regex.run(@marker_regex, string)
    case match do
      nil -> %{ result: string, length: 0, times: 0, rest: "" }
      [_, prev, marker, rest] ->
        [ length, times ] = String.split(marker, "x") |> Enum.map(&String.to_integer/1)
        %{ result: prev, length: length, times: times, rest: rest }
    end
  end

  @doc """
  Extracts the main three components of the currently given string.

  ## Examples

      iex> Mix.Tasks.Day9.apply_marker(%{ result: "", length: 1, times: 5, rest: "ax" })
      %{ result: "aaaaa", rest: "x" }

      iex> Mix.Tasks.Day9.apply_marker(%{ result: "b", length: 1, times: 5, rest: "ax" })
      %{ result: "baaaaa", rest: "x" }

      iex> Mix.Tasks.Day9.apply_marker(%{ result: "b", length: 2, times: 5, rest: "ax" })
      %{ result: "baxaxaxaxax", rest: "" }

  """
  def apply_marker(%{ result: result, length: length, times: times, rest: rest }) do
    { duplicate, nrest } = String.split_at(rest, length)
    %{ rest: nrest, result: result <> String.duplicate(duplicate, times) }
  end
end

