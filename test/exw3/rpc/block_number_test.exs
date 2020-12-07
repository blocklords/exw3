defmodule ExW3.Rpc.BlockNumberTest do
  use ExUnit.Case

  test ".block_number/0 " do
    assert ExW3.block_number() |> is_integer
  end

  test ".block_number/1 can specifiy a http endpoint" do
    assert ExW3.block_number(endpoint: Ethereumex.Config.rpc_url()) |> is_integer
  end
end
