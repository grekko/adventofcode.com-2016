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
#
# --- Part Two ---
#
# With all the decoy data out of the way, it's time to decrypt this list and get moving.
#
# The room names are encrypted by a state-of-the-art shift cipher, which is nearly unbreakable without the right software.
# However, the information kiosk designers at Easter Bunny HQ were not expecting to deal with a master cryptographer like yourself.
#
# To decrypt a room name, rotate each letter forward through the alphabet a number of times equal to the room's sector ID.
# A becomes B, B becomes C, Z becomes A, and so on. Dashes become spaces.
#
# For example, the real name for qzmt-zixmtkozy-ivhz-343 is very encrypted name.
#
# What is the sector ID of the room where North Pole objects are stored?
#
defmodule Mix.Tasks.Day4 do
  use Mix.Task

  def run(_args) do
    { :ok, input } = File.read("inputs/day4.txt")
    sectors = String.split(input, "\n") |> Enum.reject(&( 0 == String.length(&1)))
                                    |> Enum.map(fn(x) -> parse(x) end)
                                    |> Enum.filter(fn(%{ :valid => valid }) -> valid end)          # Note: There must be an easier way

                                                                              # Note: There must be an easier way
    sum = Enum.map(sectors, fn(%{ :sector_id => sector_id }) -> sector_id end) |> Enum.sum
    findings = Enum.map(sectors, fn(%{ chars: chars, sector_id: sector_id }) -> translate_word(chars, sector_id) end)
    first = Enum.find(findings, fn(%{ name: name }) -> name == "northpole object storage" end)

    IO.puts("---------------------------------")
    IO.puts("Sum: #{sum}")
    IO.puts("ID for northpole object storage: #{first.id}")
    IO.puts("---------------------------------")
  end

  @doc """
  Parses string, extracting its sector id, checksum and char frequency and validity

  ## Examples

      iex> Mix.Tasks.Day4.parse("aaaaa-bbb-z-y-x-123[abxyz]")
      %{chars: "aaaaa-bbb-z-y-x", char_frequency: [{?a, 5}, {?b, 3}, {?x, 1}, {?y, 1}, {?z, 1}], checksum: 'abxyz', calculated_checksum: 'abxyz', sector_id: 123, valid: true}

      iex> Mix.Tasks.Day4.parse("bxaxipgn-vgpst-qphzti-rdcipxcbtci-635[ipctx]")
      %{chars: "bxaxipgn-vgpst-qphzti-rdcipxcbtci", char_frequency: [{?i, 4}, {?p, 4}, {?c, 3}, {?t, 3}, {?x, 3}], checksum: 'ipctx', calculated_checksum: 'ipctx', sector_id: 635, valid: true}

  """
  def parse(string) do
    [[ _, chars, id, checksum ]] = Regex.scan(~r/(.+)-(\d+)\[(\w+)\]/, string)
    char_frequency = char_frequency(chars) |> Enum.take(5)
    checksum = to_charlist(checksum)
    calculated_checksum = Enum.map(char_frequency, fn({ char, _freq }) -> char end)
    valid = checksum == calculated_checksum
    %{ :sector_id => String.to_integer(id), chars: chars, char_frequency: char_frequency, checksum: checksum, calculated_checksum: calculated_checksum, valid: valid }
  end

  @doc """
  Parses string, extracting its sector id, checksum and char frequency and validity

  ## Examples

      iex> Mix.Tasks.Day4.translate_word("qzmt-zixmtkozy-ivhz", 343)
      %{ name: "very encrypted name", id: 343 }

  """
  def translate_word(word, translate_by) do
    translation = String.split(word, "-") |> Enum.map(fn(part) -> to_charlist(part) end)
                                          |> Enum.map(fn(charlist) ->
                                               Enum.map(charlist, fn(x) -> x + rem(translate_by, 26) end)
                                               |> Enum.map(fn(x) -> if x > 122, do: x - 26, else: x end)
                                             end)
                                          |> Enum.join(" ")
    %{ name: translation, id: translate_by }
  end

  # |> Enum.map(fn(charlist) -> Enum.map(charlist, fn(x) -> x + rem(343, 26) end) |> Enum.map(fn(x) -> if x > 122, do: x - 26, else: x end) end)
  # |> IO.inspect

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
end

