defmodule ExW3.Client do
  def call_client(method_name, opts \\ []) do
    case get_client_type(opts) do
      :http -> apply(Ethereumex.HttpClient, method_name, opts)
      :ipc -> apply(Ethereumex.IpcClient, method_name, opts)
      _ -> {:error, :invalid_client_type}
    end
  end

  defp get_client_type(opts) do
    Keyword.get(opts, :client_type) || default_config_client_type()
  end

  defp default_config_client_type do
    Application.get_env(:ethereumex, :client_type, :http)
  end
end
