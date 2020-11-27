defmodule ExW3.Utils do
  @type invalid_hex_string_error :: :invalid_hex_string

  @doc "Convert hex string to integer"
  @spec hex_to_integer(String.t()) ::
          {:ok, non_neg_integer()} | {:error, invalid_hex_string_error}
  def hex_to_integer("0x" <> hex) when hex != "", do: {:ok, String.to_integer(hex, 16)}
  def hex_to_integer(_), do: {:error, :invalid_hex_string}
end
