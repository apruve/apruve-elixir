defmodule Apruve.ClientConfig do
  @moduledoc """
  Module for handling a client configuration which consists mainly of:

  Which adapter to use.
  Which hostname etc. to use.
  Which Apruve API key key to use.

  :options is for adapter specific options
  """

  defstruct [:api_key, :hostname, :scheme, :adapter, :options]
  alias __MODULE__

  @type api_key :: String.t()
  @type hostname :: String.t()
  @type scheme :: String.t()
  @type adapter :: atom()
  @type options :: map()

  @type t :: %ClientConfig{}

  @doc """
  Build a ClientConfig struct.
  """
  @spec build_config(api_key, hostname, scheme, adapter, options) :: {:ok, ClientConfig.t()}
  def build_config(api_key, hostname, scheme, adapter, options \\ %{}) do
    {:ok,
     %ClientConfig{
       api_key: api_key,
       hostname: hostname,
       scheme: scheme,
       adapter: adapter,
       options: options
     }}
  end

  @doc false
  def from_application_config() do
    case Application.get_env(:apruve, :client_config) do
      nil ->
        {:error, :apruve_client_config_not_set}

      %{api_key: api_key, hostname: hostname, scheme: scheme, adapter: adapter} = config ->
        build_config(api_key, hostname, scheme, adapter, config[:options])

      _ ->
        {:error, :incorrect_configuration}
    end
  end
end
