defmodule ExW3.UtilsTest do
  use ExUnit.Case
  doctest ExW3.Utils

  test ".hex_to_integer/1 parses a hex encoded string to an integer" do
    assert ExW3.Utils.hex_to_integer("0x1") == {:ok, 1}
    assert ExW3.Utils.hex_to_integer("0x2") == {:ok, 2}
    assert ExW3.Utils.hex_to_integer("0x2a") == {:ok, 42}
  end

  test ".hex_to_integer/1 returns an error when the string is not a valid hexidecimal" do
    assert ExW3.Utils.hex_to_integer("0x") == {:error, :invalid_hex_string}
    assert ExW3.Utils.hex_to_integer("0a") == {:error, :invalid_hex_string}
  end
end
