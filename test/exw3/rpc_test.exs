defmodule ExW3.RpcTest do
  use ExUnit.Case
  doctest ExW3.Rpc

  test ".block_number/0 " do
    assert ExW3.block_number() > 0
  end
end
