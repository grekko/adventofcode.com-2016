# --- Day 7: Internet Protocol Version 7 ---
#
# While snooping around the local network of EBHQ, you compile a list of IP
# addresses (they're IPv7, of course; IPv6 is much too limited). You'd like to
# figure out which IPs support TLS (transport-layer snooping).
#
# An IP supports TLS if it has an Autonomous Bridge Bypass Annotation, or ABBA.
# An ABBA is any four-character sequence which consists of a pair of two
# different characters followed by the reverse of that pair, such as xyyx or
# abba. However, the IP also must not have an ABBA within any hypernet
# sequences, which are contained by square brackets.
#
# For example:
#
# abba[mnop]qrst supports TLS
#   (abba outside square brackets).
#
# abcd[bddb]xyyx does not support TLS
#   (bddb is within square brackets, even though xyyx is outside square brackets).
#
# aaaa[qwer]tyui does not support TLS
#   (aaaa is invalid; the interior characters must be different).
#
# ioxxoj[asdfgh]zxcvbn supports TLS
#   (oxxo is outside square brackets, even though it's within a larger string).
#
# How many IPs in your puzzle input support TLS?
#
# --- Part Two ---
#
# You would also like to know which IPs support SSL (super-secret listening).
#
# An IP supports SSL if it has an Area-Broadcast Accessor, or ABA, anywhere in
# the supernet sequences (outside any square bracketed sections), and a
# corresponding Byte Allocation Block, or BAB, anywhere in the hypernet
# sequences. An ABA is any three-character sequence which consists of the same
# character twice with a different character between them, such as xyx or aba.
# A corresponding BAB is the same characters but in reversed positions: yxy and
# bab, respectively.
#
# For example:
#
# aba[bab]xyz supports SSL
#   (aba outside square brackets with corresponding bab within square brackets).
#
# xyx[xyx]xyx does not support SSL
#   (xyx, but no corresponding yxy).
#
# aaa[kek]eke supports SSL
#   (eke in supernet with corresponding kek in hypernet; the aaa sequence is not related, because the interior character must be different).
#
# zazbz[bzb]cdb supports SSL
#   (zaz has no corresponding aza, but zbz has a corresponding bzb, even though zaz and zbz overlap).
#
#
# How many IPs in your puzzle input support SSL?

defmodule Mix.Tasks.Day7 do
  use Mix.Task

  def run(_args) do
    { :ok, input } = File.read("inputs/day7.txt")

    ips_with_tls_support_count = input
      |> String.split("\n")
      |> Enum.map(&supports_tls?/1)
      |> Enum.filter(fn(x) -> x end)
      |> Enum.count

    ips_with_ssl_support_count = input
      |> String.split("\n")
      |> Enum.map(&supports_ssl?/1)
      |> Enum.filter(fn(x) -> x end)
      |> Enum.count

    IO.puts("---------------------------------")
    IO.puts("IPs w/ TLS Support: #{ips_with_tls_support_count}")
    IO.puts("IPs w/ SSL Support: #{ips_with_ssl_support_count}")
    IO.puts("---------------------------------")
  end

  @doc """
  Verifies wether the given IPv7 supports SSL.

  ## Examples

      iex> Mix.Tasks.Day7.supports_ssl?("aba[bab]xyz")
      true

      iex> Mix.Tasks.Day7.supports_ssl?("xyx[xyx]xyx[abcba]abc")
      false

      iex> Mix.Tasks.Day7.supports_ssl?("aaa[kek]eke")
      true

      iex> Mix.Tasks.Day7.supports_ssl?("zazbz[bzb]cdb")
      true

      iex> Mix.Tasks.Day7.supports_ssl?("kak[akkjhaha]aha[xxkjj]o")
      true

      iex> Mix.Tasks.Day7.supports_ssl?("  konztznxgyjsvynvl[fjejsdhfcynplct]fdnapcnuzqsgwxbdulv[fmxdbdjrhtqglsvtwwg]xumwevxvrhwrqblhzbh[paxrxvxynvppmwt]znpjdeeqlribvbqm")
      true

  """
  def supports_ssl?(string) do
    supernets = extract_supernets(string)
    Regex.scan(~r/\[(\w+)\]/, string, capture: :all_but_first)
      |> Enum.map(&hd/1)
      |> Enum.map(&find_abas/1)
      |> List.flatten
      |> Enum.map(fn(abas) ->
        <<a, b, a>> = abas
        bab = <<b, a, b>>
        Enum.any?(supernets, fn(net) -> String.contains?(net, bab) end)
        end)
      |> Enum.any?
  end

  @doc """
  Extracts supernet parts of given IPv7

  ## Examples

      iex> Mix.Tasks.Day7.extract_supernets("b[a]c")
      ["b", "c"]

      iex> Mix.Tasks.Day7.extract_supernets("b[a]c[xyz]d")
      ["b", "c", "d"]

      iex> Mix.Tasks.Day7.extract_supernets("[a]c[x]")
      ["c"]

  """
  def extract_supernets(string) do
    Regex.replace(~r/\[\w+\]/, string, "-")
      |> String.split("-")
      |> Enum.reject(&(byte_size(&1) == 0))
  end


  @doc """
  Checks for aba string.

  ## Examples

      iex> Mix.Tasks.Day7.find_abas("bab")
      ["bab"]

      iex> Mix.Tasks.Day7.find_abas("bbba")
      []

      iex> Mix.Tasks.Day7.find_abas("ghgxzx")
      ["ghg", "xzx"]

      iex> Mix.Tasks.Day7.find_abas("ghgghg")
      ["ghg"]

      iex> Mix.Tasks.Day7.find_abas("paxrxvxynvppmwt")
      ["xrx", "xvx"]

  """
  def find_abas(string) do
    Regex.scan(~r/(?=(\w)(?!\1)(\w)(\1))/, string, capture: :all_but_first)
      |> Enum.map(&Enum.join/1)
      |> Enum.uniq
  end

  @doc """
  Verifies wether the given IPv7 supports TLS.

  ## Examples

      iex> Mix.Tasks.Day7.supports_tls?("abba[mnop]qrst")
      true

      iex> Mix.Tasks.Day7.supports_tls?("abcd[bddb]xyyx")
      false

      iex> Mix.Tasks.Day7.supports_tls?("aaaa[qwer]tyui")
      false

      iex> Mix.Tasks.Day7.supports_tls?("ioxxoj[asdfgh]zxcvbn")
      true

  """
  def supports_tls?(string) do
    positive = Regex.scan(~r/(\w+)/, string, capture: :all_but_first)
      |> Enum.map(&hd/1)
      |> Enum.map(&has_abba?/1)
      |> Enum.any?
    negative = Regex.scan(~r/\[(\w+)\]/, string, capture: :all_but_first)
      |> Enum.map(&hd/1)
      |> Enum.map(&has_abba?/1)
      |> Enum.any?
    positive && !negative
  end

  @doc """
  Verifies wether the given string includes an ABBA

  ## Examples

      iex> Mix.Tasks.Day7.has_abba?("xabba")
      true

      iex> Mix.Tasks.Day7.has_abba?("xaaaa")
      false

      iex> Mix.Tasks.Day7.has_abba?("rvaycmplefdvbrchc")
      false

      iex> Mix.Tasks.Day7.has_abba?("mnxkwzpqqpfrxmlcmt")
      true

  """
  def has_abba?(string) do
    string
    |> to_charlist
    |> _has_abba?
    |> Enum.any?
  end

  defp _has_abba?(list) do
    _has_abba?(list, [])
  end

  defp _has_abba?([ head | tail ], acc) do
    result = if length(tail) >= 3 do
      [ b1, b2, head2 | _ ] = tail
      head == head2 && b1 == b2 && head != b1
    else
      false
    end
    _has_abba?(tail, acc ++ [ result ])
  end

  defp _has_abba?([], acc) do
    acc
  end
end

