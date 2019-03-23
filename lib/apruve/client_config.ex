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

  @doc """
  Get a `ClientConfig` from the application configuration.

  Returns a `ClientConfig` struct tagged with `:ok` in a tuple if successful.

  See `from_application_config!/0` to get it without the tuple and raising an error
  if unsuccessful.
  """
  @spec from_application_config() :: {:ok, t()} | {:error, atom}
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

  @doc """
  Get a ClientConfig from the application configuration.

  Raises an error if a correct configuration is not found.

  See `from_application_config/0` to get an {:ok, ClientConfig} tuple instead
  or an {:error, ...} tuple instead of a raised error.
  """
  def from_application_config!() do
    case from_application_config() do
      {:ok, client_config} ->
        client_config

      error ->
        raise "Could not get client config from app configuration: #{inspect(error)}"
    end
  end
end
