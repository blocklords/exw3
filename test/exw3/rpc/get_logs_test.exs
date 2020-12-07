defmodule ExW3.Rpc.GetLogsTest do
  use ExUnit.Case

  setup_all do
    ExW3.Contract.start_link()

    %{
      simple_storage_abi: ExW3.load_abi("test/examples/build/SimpleStorage.abi"),
      event_tester_abi: ExW3.load_abi("test/examples/build/EventTester.abi"),
      accounts: ExW3.accounts()
    }
  end

  test ".get_logs/1", context do
    ExW3.Contract.register(:EventTester, abi: context[:event_tester_abi])

    {:ok, address, _} =
      ExW3.Contract.deploy(
        :EventTester,
        bin: ExW3.load_bin("test/examples/build/EventTester.bin"),
        options: %{
          gas: 300_000,
          from: Enum.at(context[:accounts], 0)
        }
      )

    ExW3.Contract.at(:EventTester, address)

    {:ok, from_block} = ExW3.block_number() |> ExW3.Utils.integer_to_hex()

    {:ok, simple_tx_hash} =
      ExW3.Contract.send(:EventTester, :simple, ["Hello, World!"], %{
        from: Enum.at(context[:accounts], 0),
        gas: 30_000
      })

    {:ok, _} =
      ExW3.Contract.send(:EventTester, :simpleIndex, ["Hello, World!"], %{
        from: Enum.at(context[:accounts], 0),
        gas: 30_000
      })

    filter = %{
      fromBlock: from_block,
      toBlock: "latest",
      topics: [ExW3.keccak256("Simple(uint256,bytes32)")]
    }

    assert {:ok, logs} = ExW3.get_logs(filter)
    assert Enum.count(logs) == 1

    log = Enum.at(logs, 0)
    assert log["transactionHash"] == simple_tx_hash
  end
end
