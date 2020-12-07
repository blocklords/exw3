defmodule ExW3.Rpc do
  import ExW3.Utils
  import ExW3.Client

  @type invalid_hex_string_error :: ExW3.Utils.invalid_hex_string_error()
  @type request_error :: Ethereumex.Client.Behaviour.error()
  @type opts :: keyword

  @spec block_number(opts) ::
          non_neg_integer() | {:error, invalid_hex_string_error} | request_error
  def block_number(opts) do
    with {:ok, hex} <- call_client(:eth_block_number, opts),
         {:ok, block_number} <- hex_to_integer(hex) do
      block_number
    else
      err -> err
    end
  end

  @type latest :: String.t()
  @type earliest :: String.t()
  @type pending :: String.t()
  @type log_filter :: %{
          optional(:address) => String.t(),
          optional(:fromBlock) => latest | earliest | pending | String.t(),
          optional(:toBlock) => latest | earliest | pending | String.t(),
          optional(:topics) => [String.t()],
          optional(:blockhash) => String.t()
        }

  @spec get_logs(log_filter, opts) :: {:ok, list} | {:error, term} | request_error
  def get_logs(filter, opts) do
    with {:ok, _} = result <- call_client(:eth_get_logs, [filter, opts]) do
      result
    else
      err -> err
    end
  end
end
