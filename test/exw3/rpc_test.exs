defmodule ExW3.RpcTest do
  use ExUnit.Case

  @http_rpc_url "http://foo/bar"
  @ipc_rpc_url "/foo/bar"

  test ".block_number/0 " do
    assert ExW3.block_number() |> is_integer
  end

  test ".block_number/1 can override the client" do
    assert ExW3.block_number(client_type: :http, url: @http_rpc_url) |> is_integer
    assert ExW3.block_number(client_type: :ipc, url: @ipc_rpc_url) |> is_integer
  end
end
