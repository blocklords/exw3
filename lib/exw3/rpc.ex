defmodule ExW3.Rpc do
  import ExW3.Utils
  import ExW3.Client

  @type invalid_hex_string_error :: ExW3.Utils.invalid_hex_string_error()
  @type request_error :: any

  @doc "Returns the current block number"
  @spec block_number() :: integer() | {:error, invalid_hex_string_error | request_error}
  def block_number do
    with {:ok, hex} <- call_client(:eth_block_number),
         {:ok, block_number} <- hex_to_integer(hex) do
      block_number
    else
      err -> err
    end
  end
end
