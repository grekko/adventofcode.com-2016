# --- Day 6: Signals and Noise ---
#
# Something is jamming your communications with Santa. Fortunately, your signal
# is only partially jammed, and protocol in situations like this is to switch
# to a simple repetition code to get the message through.
#
# In this model, the same message is sent repeatedly. You've recorded the
# repeating message signal (your puzzle input), but the data seems quite
# corrupted - almost too badly to recover. Almost.
#
# All you need to do is figure out which character is most frequent for each
# position. For example, suppose you had recorded the following messages:
#
# eedadn
# drvtee
# eandsr
# raavrd
# atevrs
# tsrnev
# sdttsa
# rasrtv
# nssdts
# ntnada
# svetve
# tesnvt
# vntsnd
# vrdear
# dvrsen
# enarar
# The most common character in the first column is e; in the second, a; in the third, s, and so on.
# Combining these characters returns the error-corrected message, easter.
#
# Given the recording in your puzzle input, what is the error-corrected version of the message being sent?

defmodule Mix.Tasks.Day6 do
  use Mix.Task

  def run(_args) do
    { :ok, input } = File.read("inputs/day6.txt")
    ocurrences = String.split(input, "\n")
      |> List.delete_at(-1)
      |> Enum.map(&to_charlist/1)
      |> transpose
      |> Enum.map(&(parse(&1)))

    most_frequent = ocurrences
      |> Enum.map(&hd/1)
      |> Enum.map(fn({ char, _count }) -> char end)

    least_frequent = ocurrences
      |> Enum.map(&Enum.reverse/1)
      |> Enum.map(&hd/1)
      |> Enum.map(fn({ char, _count }) -> char end)

    IO.puts("---------------------------------")
    IO.puts("Most frequent: #{most_frequent}")
    IO.puts("Least frequent: #{least_frequent}")
    IO.puts("---------------------------------")
  end

  @doc """
  Tranposes a matrix. Think of: Flips rows and columns in a spreadsheet.

  ## Examples

      iex> Mix.Tasks.Day6.transpose(['abc', 'def', 'ghi'])
      ['adg', 'beh', 'cfi']

  """

  # Note: Taken from https://github.com/joskov/advent2016/blob/master/day06/task1.exs
  def transpose([[] | _]), do: []
  def transpose(list) do
    [ Enum.map(list, &hd/1) | transpose(Enum.map(list, &tl/1)) ]
  end

  @doc """
  Counts occurences of letters in a multi-line string, sums and sorts by sum.

  ## Examples

      iex> Mix.Tasks.Day6.ocurrences_sum("abc\\naac\\nacc\\nbbc\\n")
      [{ ?c, 5 }, { ?a, 4 }, { ?b, 3 }]

  """
  def ocurrences_sum(string) do
    to_charlist(String.replace(string, ~r/\W/, ""))
      |> parse
  end

  @doc """
  Counts occurences of letters, sorts them by sum.

  ## Examples

      iex> Mix.Tasks.Day6.parse('aaaacccccbb')
      [{ ?c, 5 }, { ?a, 4 }, { ?b, 2 }]

  """
  def parse(list) do
    list
      |> Enum.group_by(fn(x) -> x end)
      |> Enum.map(fn({ int, chars }) -> { int, length(chars) } end)
      |> Enum.sort(fn({ _, count1 }, { _, count2 }) -> count1 > count2 end)
  end

end

