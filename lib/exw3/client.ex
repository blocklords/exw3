defmodule ExW3.Client do
  def call_client(method_name, opts \\ []) do
    client_type = Keyword.get(opts, :client_type) || default_config_client_type()
    opts = Keyword.delete(opts, :client_type)

    case client_type do
      :http -> apply(Ethereumex.HttpClient, method_name, [opts])
      :ipc -> apply(Ethereumex.IpcClient, method_name, [opts])
      _ -> {:error, :invalid_client_type}
    end
  end

  defp default_config_client_type do
    Application.get_env(:ethereumex, :client_type, :http)
  end
end
