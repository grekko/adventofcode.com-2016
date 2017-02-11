# --- Day 5: How About a Nice Game of Chess? ---
#
# You are faced with a security door designed by Easter Bunny engineers that seem to have acquired
# most of their security knowledge by watching hacking movies.
#
# The eight-character password for the door is generated one character at a time by finding the
# MD5 hash of some Door ID (your puzzle input) and an increasing integer index (starting with 0).
#
# A hash indicates the next character in the password if its hexadecimal representation starts with
# five zeroes. If it does, the sixth character in the hash is the next character of the password.
#
# For example, if the Door ID is abc:
#
# The first index which produces a hash that starts with five zeroes is 3231929, which we find by
# hashing abc3231929; the sixth character of the hash, and thus the first character of the password, is 1.
#
# 5017308 produces the next interesting hash, which starts with 000008f82..., so the second character
# of the password is 8.
#
# The third time a hash starts with five zeroes is for abc5278568, discovering the character f.
# In this example, after continuing this search a total of eight times, the password is 18f47a30.
#
# Given the actual Door ID, what is the password?
#
# Your puzzle input is ugkcyxxp.
#
# --- Part Two ---
#
# As the door slides open, you are presented with a second door that uses a
# slightly more inspired security mechanism. Clearly unimpressed by the last
# version (in what movie is the password decrypted in order?!), the Easter
# Bunny engineers have worked out a better solution.
#
# Instead of simply filling in the password from left to right, the hash now
# also indicates the position within the password to fill. You still look for
# hashes that begin with five zeroes; however, now, the sixth character
# represents the position (0-7), and the seventh character is the character to
# put in that position.
#
# A hash result of 000001f means that f is the second character in the
# password. Use only the first result for each position, and ignore invalid
# positions.
#
# For example, if the Door ID is abc:
#
# The first interesting hash is from abc3231929, which produces 0000015...; so,
# 5 goes in position 1: _5______.
#
# In the previous method, 5017308 produced an interesting hash; however, it is
# ignored, because it specifies an invalid position (8).
#
# The second interesting hash is at index 5357525, which produces 000004e...;
# so, e goes in position 4: _5__e___.
#
# You almost choke on your popcorn as the final character falls into place,
# producing the password 05ace8e3.
#
# Given the actual Door ID and this new method, what is the password? Be extra
# proud of your solution if it uses a cinematic "decrypting" animation.
#
defmodule Mix.Tasks.Day5 do
  use Mix.Task

  def run(_args) do
    { :ok, input } = File.read("inputs/day5.txt")
    input = String.split(input, "\n") |> List.first
    # password = crack_password(input)
    tough_password = crack_tougher_password(input)

    IO.inspect(input)

    IO.puts("---------------------------------")
    # IO.puts("Password: #{password}")
    IO.puts("Tough Password: #{tough_password}")
    IO.puts("---------------------------------")
  end

  @doc """
  Cracks the password.

  ## Examples

      iex> Mix.Tasks.Day5.crack_password("abc", "18F47A3", 8605828)
      "18F47A30"

  """
  def crack_password(input, password \\ "", counter \\ 1) do
    if String.length(password) == 8 do
      password
    else
      %{ id: id, hash: hash } = find_hash(input, counter)
      crack_password(input, "#{password}#{String.at(hash, 5)}", id+1)
    end
  end

  @doc """
  Cracks the tougher password.

  ## Examples

      iex> Mix.Tasks.Day5.crack_tougher_password("abc", ["a", nil, "a", "a", "a", "a", "a", "a"], 3231929)
      "a5aaaaaa"

  """
  def crack_tougher_password(input, password \\ [nil, nil, nil, nil, nil, nil, nil, nil], counter \\ 1) do
    # TODO: Move this into run
    # IO.puts("Current password: #{Enum.map(password, fn(x) -> if x == nil, do: "_", else: x end) |> Enum.join}, counter: #{counter}")
    if Enum.all?(password) do
      Enum.join(password)
    else
      %{ id: id, hash: hash } = find_hash(input, counter)
      # LEARNING: handle indifferent return types e.g. tuple (success) vs. atom (:error) with `cond`
      position = case String.at(hash, 5) |> Integer.parse do
        { position, _ } -> if position >= 0 and position < 8, do: position, else: :error
        :error -> :error
      end
      password = if position != :error and Enum.at(password, position) == nil do
        List.replace_at(password, position, String.at(hash, 6))
      else
        password
      end
      crack_tougher_password(input, password, id+1)
    end
  end

  @doc """
  Finds next hash that begins with the given sequence of hex codes.
  May never terminate.

  ## Examples

      iex> Mix.Tasks.Day5.find_hash("abc", 3231928)
      %{ hash: "00000155F8105DFF7F56EE10FA9B9ABD", id: 3231929 }

      iex> Mix.Tasks.Day5.find_hash("abc", 5017307)
      %{ hash: "000008F82C5B3924A1ECBEBF60344E00", id: 5017308 }

  """
  def find_hash(payload, index \\ 1) do
    hash = :crypto.hash(:md5, "#{payload}#{index}") |> Base.encode16
    if String.starts_with?(hash, "00000") do
      %{ hash: hash, id: index }
    else
      find_hash(payload, index+1)
    end
  end
end

