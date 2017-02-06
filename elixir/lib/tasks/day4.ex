# --- Day 4: Security Through Obscurity ---
#
# Finally, you come across an information kiosk with a list of rooms. Of course, the list is encrypted and full of decoy data, but the instructions to decode the list are barely hidden nearby. Better remove the decoy data first.
#
# Each room consists of an encrypted name (lowercase letters separated by dashes) followed by a dash, a sector ID, and a checksum in square brackets.
#
# A room is real (not a decoy) if the checksum is the five most common letters in the encrypted name, in order, with ties broken by alphabetization. For example:
#
# aaaaa-bbb-z-y-x-123[abxyz] is a real room because the most common letters are a (5), b (3), and then a tie between x, y, and z, which are listed alphabetically.
# a-b-c-d-e-f-g-h-987[abcde] is a real room because although the letters are all tied (1 of each), the first five are listed alphabetically.
# not-a-real-room-404[oarel] is a real room.
# totally-real-room-200[decoy] is not.
# Of the real rooms from the list above, the sum of their sector IDs is 1514.
#
# What is the sum of the sector IDs of the real rooms?
defmodule Mix.Tasks.Day4 do
  use Mix.Task

  def run(_args) do
    { :ok, input } = File.read("inputs/day4.txt")
    IO.inspect(input)

    IO.puts("---------------------------------")
    IO.puts("---------------------------------")
  end

  # Examples:
  # aaaaa-bbb-z-y-x-123[abxyz]
  # a-b-c-d-e-f-g-h-987[abcde]
  # not-a-real-room-404[oarel]
  # totally-real-room-200[decoy]

  @doc """
  Checks wether given string is valid

  ## Examples

      iex> Mix.Tasks.Day4.is_valid?("aaaaa-bbb-z-y-x-123[abxyz]")
      true

  """
  def is_valid?(string) do
    [[ _, chars, id, checksum ]] = Regex.scan(~r/(.+)-(\d+)\[(\w+)\]/, string)
    char_frequency = char_frequency(chars)
  end

  @doc """
  Transforms horizontal triangles to vertical triangles.

  ## Examples

      iex> Mix.Tasks.Day4.char_frequency("not-a-real-room")
      [{ ?o, 3 }, { ?a, 2 }, { ?r, 2 }, { ?e, 1 }, { ?l, 1 }, { ?m, 1 }, { ?n, 1 }, { ?t, 1 }]

  """
  def char_frequency(word) do
    to_charlist(word) |> Enum.filter(fn(x) -> x != ?- end)
                      |> Enum.group_by(fn(x) -> x end)
                      |> Map.to_list
                      |> Enum.map(fn({ char, chars }) -> { char, length(chars) } end)
                      |> Enum.sort(fn({ char1, count1 }, { char2, count2 }) -> count1 > count2 or if count1 == count2 and char1 < char2, do: true, else: false end)
  end

  @doc """
  Transforms horizontal triangles to vertical triangles.

  ## Examples

      iex> Mix.Tasks.Day4.sort_stuff([{ ?a, 0 }, { ?b, 1 }, { ?c, 1 }, { ?d, 2 }])
      [{ ?d, 2 }, { ?b, 1 }, { ?c, 1 }, {  ?a, 0 }]

  """
  def sort_stuff(keyword_list) do
    Enum.sort(keyword_list, fn({ char1, count1 }, { char2, count2 }) -> count1 > count2 or if count1 == count2 and char1 < char2, do: true, else: false end)
  end
end

