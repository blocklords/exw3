defmodule ExW3 do
  Module.register_attribute(__MODULE__, :unit_map, persist: true, accumulate: false)
  Module.register_attribute(__MODULE__, :client_type, persist: true, accumulate: false)

  @unit_map %{
    :noether => 0,
    :wei => 1,
    :kwei => 1_000,
    :Kwei => 1_000,
    :babbage => 1_000,
    :femtoether => 1_000,
    :mwei => 1_000_000,
    :Mwei => 1_000_000,
    :lovelace => 1_000_000,
    :picoether => 1_000_000,
    :gwei => 1_000_000_000,
    :Gwei => 1_000_000_000,
    :shannon => 1_000_000_000,
    :nanoether => 1_000_000_000,
    :nano => 1_000_000_000,
    :szabo => 1_000_000_000_000,
    :microether => 1_000_000_000_000,
    :micro => 1_000_000_000_000,
    :finney => 1_000_000_000_000_000,
    :milliether => 1_000_000_000_000_000,
    :milli => 1_000_000_000_000_000,
    :ether => 1_000_000_000_000_000_000,
    :kether => 1_000_000_000_000_000_000_000,
    :grand => 1_000_000_000_000_000_000_000,
    :mether => 1_000_000_000_000_000_000_000_000,
    :gether => 1_000_000_000_000_000_000_000_000_000,
    :tether => 1_000_000_000_000_000_000_000_000_000_000
  }

  @spec get_client_type() :: atom()
  def get_client_type do
    Application.get_env(:ethereumex, :client_type, :http)
  end

  @spec get_unit_map() :: map()
  @doc "Returns the map used for ether unit conversion"
  def get_unit_map do
    @unit_map
  end

  @spec to_wei(integer(), atom()) :: integer()
  @doc "Converts the value to whatever unit key is provided. See unit map for details."
  def to_wei(num, key) do
    if @unit_map[key] do
      num * @unit_map[key]
    else
      throw("#{key} not valid unit")
    end
  end

  @spec from_wei(integer(), atom()) :: integer() | float() | no_return
  @doc "Converts the value to whatever unit key is provided. See unit map for details."
  def from_wei(num, key) do
    if @unit_map[key] do
      num / @unit_map[key]
    else
      throw("#{key} not valid unit")
    end
  end

  @spec keccak256(binary()) :: binary()
  @doc "Returns a 0x prepended 32 byte hash of the input string"
  def keccak256(string) do
    {:ok, hash} = ExKeccak.hash_256(string)

    Enum.join(["0x", hash |> Base.encode16(case: :lower)], "")
  end

  @spec bytes_to_string(binary()) :: binary()
  @doc "converts Ethereum style bytes to string"
  def bytes_to_string(bytes) do
    bytes
    |> Base.encode16(case: :lower)
    |> String.replace_trailing("0", "")
    |> Base.decode16!(case: :lower)
  end

  @spec format_address(binary()) :: integer()
  @doc "Converts an Ethereum address into a form that can be used by the ABI encoder"
  def format_address(address) do
    address
    |> String.slice(2..-1)
    |> Base.decode16!(case: :lower)
    |> :binary.decode_unsigned()
  end

  @spec to_address(binary()) :: binary()
  @doc "Converts bytes to Ethereum address"
  def to_address(bytes) do
    Enum.join(["0x", bytes |> Base.encode16(case: :lower)], "")
  end

  @spec to_checksum_address(binary()) :: binary()
  @doc "returns a checksummed address"
  def to_checksum_address(address) do
    address = address |> String.downcase() |> String.replace(~r/^0x/, "")

    {:ok, hash_bin} = ExKeccak.hash_256(address)

    hash =
      hash_bin
      |> Base.encode16(case: :lower)
      |> String.replace(~r/^0x/, "")

    keccak_hash_list =
      hash
      |> String.split("", trim: true)
      |> Enum.map(fn x -> elem(Integer.parse(x, 16), 0) end)

    list_arr =
      for n <- 0..(String.length(address) - 1) do
        number = Enum.at(keccak_hash_list, n)

        cond do
          number >= 8 -> String.upcase(String.at(address, n))
          true -> String.downcase(String.at(address, n))
        end
      end

    "0x" <> List.to_string(list_arr)
  end

  @doc "checks if the address is a valid checksummed address"
  @spec is_valid_checksum_address(binary()) :: boolean()
  def is_valid_checksum_address(address) do
    to_checksum_address(address) == address
  end

  @spec accounts() :: list()
  @doc "returns all available accounts"
  def accounts do
    case ExW3.Client.call_client(:eth_accounts) do
      {:ok, accounts} -> accounts
      err -> err
    end
  end

  @spec to_decimal(binary()) :: number()
  @doc "Converts ethereum hex string to decimal number"
  def to_decimal(hex_string) do
    hex_string
    |> String.slice(2..-1)
    |> String.to_integer(16)
  end

  @spec block_number() :: integer()
  @doc "Returns the current block number"
  def block_number do
    case ExW3.Client.call_client(:eth_block_number) do
      {:ok, block_number} ->
        block_number |> to_decimal

      err ->
        err
    end
  end

  @spec balance(binary()) :: integer() | {:error, any()}
  @doc "Returns current balance of account"
  def balance(account) do
    case ExW3.Client.call_client(:eth_get_balance, [account]) do
      {:ok, balance} ->
        balance |> to_decimal

      err ->
        err
    end
  end

  @spec keys_to_decimal(map(), list()) :: map()
  def keys_to_decimal(map, keys) do
    for k <- keys, into: %{}, do: {k, map |> Map.get(k) |> to_decimal()}
  end

  @spec tx_receipt(binary()) :: {:ok, map()} | {:error, any()}
  @doc "Returns transaction receipt for specified transaction hash(id)"
  def tx_receipt(tx_hash) do
    case ExW3.Client.call_client(:eth_get_transaction_receipt, [tx_hash]) do
      {:ok, nil} ->
        {:error, :not_mined}

      {:ok, receipt} ->
        decimal_res = keys_to_decimal(receipt, ~w(blockNumber cumulativeGasUsed gasUsed))

        {:ok, Map.merge(receipt, decimal_res)}

      err ->
        {:error, err}
    end
  end

  @spec block(integer()) :: any() | {:error, any()}
  @doc "Returns block data for specified block number"
  def block(block_number) do
    case ExW3.Client.call_client(:eth_get_block_by_number, [block_number, true]) do
      {:ok, block} -> block
      err -> err
    end
  end

  @spec new_filter(map()) :: binary() | {:error, any()}
  @doc "Creates a new filter, returns filter id. For more sophisticated use, prefer ExW3.Contract.filter."
  def new_filter(map) do
    case ExW3.Client.call_client(:eth_new_filter, [map]) do
      {:ok, filter_id} -> filter_id
      err -> err
    end
  end

  @spec get_filter_changes(binary()) :: any()
  @doc "Gets event changes (logs) by filter. Unlike ExW3.Contract.get_filter_changes it does not return the data in a formatted way"
  def get_filter_changes(filter_id) do
    case ExW3.Client.call_client(:eth_get_filter_changes, [filter_id]) do
      {:ok, changes} -> changes
      err -> err
    end
  end

  @spec uninstall_filter(binary()) :: boolean() | {:error, any()}
  @doc "Uninstalls filter from the ethereum node"
  def uninstall_filter(filter_id) do
    case ExW3.Client.call_client(:eth_uninstall_filter, [filter_id]) do
      {:ok, result} -> result
      err -> err
    end
  end

  @spec mine(integer()) :: any() | {:error, any()}
  @doc "Mines number of blocks specified. Default is 1"
  def mine(num_blocks \\ 1) do
    for _ <- 0..(num_blocks - 1) do
      ExW3.Client.call_client(:request, ["evm_mine", [], []])
    end
  end

  @spec personal_list_accounts(list()) :: {:ok, list()} | {:error, any()}
  @doc "Using the personal api, returns list of accounts."
  def personal_list_accounts(opts \\ []) do
    ExW3.Client.call_client(:request, ["personal_listAccounts", [], opts])
  end

  @spec personal_new_account(binary(), list()) :: {:ok, binary()} | {:error, any()}
  @doc "Using the personal api, this method creates a new account with the passphrase, and returns new account address."
  def personal_new_account(password, opts \\ []) do
    ExW3.Client.call_client(:request, ["personal_newAccount", [password], opts])
  end

  @spec personal_unlock_account(binary(), list()) :: {:ok, boolean()} | {:error, any()}
  @doc "Using the personal api, this method unlocks account using the passphrase provided, and returns a boolean."
  ### E.g. ExW3.personal_unlock_account(["0x1234","Password",30], [])
  def personal_unlock_account(params, opts \\ []) do
    ExW3.Client.call_client(:request, ["personal_unlockAccount", params, opts])
  end

  @spec personal_send_transaction(map(), binary(), list()) :: {:ok, binary()} | {:error, any()}
  @doc "Using the personal api, this method sends a transaction and signs it in one call, and returns a transaction id hash."
  def personal_send_transaction(param_map, passphrase, opts \\ []) do
    ExW3.Client.call_client(:request, ["personal_sendTransaction", [param_map, passphrase], opts])
  end

  @spec personal_sign_transaction(map(), binary(), list()) :: {:ok, map()} | {:error, any()}
  @doc "Using the personal api, this method signs a transaction, and returns the signed transaction."
  def personal_sign_transaction(param_map, passphrase, opts \\ []) do
    ExW3.Client.call_client(:request, ["personal_signTransaction", [param_map, passphrase], opts])
  end

  @spec personal_sign(binary(), binary(), binary(), list()) :: {:ok, binary()} | {:error, any()}
  @doc "Using the personal api, this method calculates an Ethereum specific signature, and returns that signature."
  def personal_sign(data, address, passphrase, opts \\ []) do
    ExW3.Client.call_client(:request, ["personal_sign", [data, address, passphrase], opts])
  end

  @spec personal_ec_recover(binary(), binary(), []) :: {:ok, binary()} | {:error, any()}
  @doc "Using the personal api, this method returns the address associated with the private key that was used to calculate the signature with personal_sign."
  def personal_ec_recover(data0, data1, opts \\ []) do
    ExW3.Client.call_client(:request, ["personal_ecRecover", [data0, data1], opts])
  end

  @spec eth_sign(binary(), binary(), list()) :: {:ok, binary()} | {:error, any()}
  @doc "Calculates an Ethereum specific signature and signs the data provided, using the accounts private key"
  def eth_sign(data0, data1, opts \\ []) do
    ExW3.Client.call_client(:request, ["eth_sign", [data0, data1], opts])
  end

  @spec encode_event(binary()) :: binary()
  @doc "Encodes event based on signature"
  def encode_event(signature) do
    {:ok, hash} = ExKeccak.hash_256(signature)

    Base.encode16(hash, case: :lower)
  end

  @spec eth_call(list()) :: any()
  @doc "Simple eth_call to client. Recommended to use ExW3.Contract.call instead."
  def eth_call(arguments) do
    ExW3.Client.call_client(:eth_call, arguments)
  end

  @spec eth_send(list()) :: any()
  @doc "Simple eth_send_transaction. Recommended to use ExW3.Contract.send instead."
  def eth_send(arguments) do
    ExW3.Client.call_client(:eth_send_transaction, arguments)
  end
end
