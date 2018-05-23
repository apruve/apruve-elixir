defmodule Apruve.Adapters.Hackney do
  @moduledoc """
  An HTTPS adapter that uses Hackney for HTTPS requests.
  """

  require Logger

  @behaviour Apruve.Adapter
  @api_version "v4"

  alias Apruve.ClientConfig
  alias Apruve.Adapter

  @impl true
  @spec get(String.t(), ClientConfig.t()) ::
          {:ok, String.t(), Adapter.http_status_code(), any} | {:error, any}
  def get(rest_of_url, client_config) do
    url = full_url(client_config.scheme, client_config.hostname, rest_of_url)

    Logger.debug(fn -> "GET begin url: #{url}" end)
    result = :hackney.request(:get, url, headers(client_config.api_key), [])
    Logger.debug(fn -> "GET result for #{url}:\n#{inspect(result)}" end)

    case result do
      {:ok, http_status, _headers, client_ref} when http_status < 400 ->
        {:ok, body} = :hackney.body(client_ref)
        Logger.debug(fn -> "GET result body for #{url}: #{inspect(body)}\n" end)
        {:ok, body, http_status, client_ref}

      {:ok, 404, _, _} ->
        {:error, :not_found}

      not_ok ->
        {:error, not_ok}
    end
  end

  @impl true
  def post(rest_of_url, body, client_config) do
    url = full_url(client_config.scheme, client_config.hostname, rest_of_url)
    Logger.debug(fn -> "POST begin url: #{url} body:\n" <> inspect(body) end)
    result = :hackney.request(:post, url, headers(client_config.api_key), body, [])
    Logger.debug(fn -> "POST result for #{url}:\n#{inspect(result)}" end)

    case result do
      {:ok, http_status, _headers, client_ref} when http_status < 400 ->
        {:ok, body} = :hackney.body(client_ref)
        Logger.debug(fn -> "POST result body for #{url}:\n#{inspect(body)}" end)
        {:ok, body, http_status, client_ref}

      {:ok, 404, _, client_ref} ->
        {:ok, body} = :hackney.body(client_ref)
        Logger.debug(fn -> "404 error. POST result body for #{url}:\n#{inspect(body)}" end)
        {:error, :not_found}

      {:ok, http_status, headers, client_ref} ->
        {:ok, body} = :hackney.body(client_ref)
        Logger.debug(fn -> "Error. POST result body for #{url}:\n#{inspect(body)}" end)
        {:error, {body, http_status, headers}}

      not_ok ->
        {:error, not_ok}
    end
  end

  @impl true
  def put(rest_of_url, body, client_config) do
    url = full_url(client_config.scheme, client_config.hostname, rest_of_url)
    Logger.debug(fn -> "PUT begin url: #{url} body:\n" <> inspect(body) end)
    result = :hackney.request(:post, url, headers(client_config.api_key), body, [])
    Logger.debug(fn -> "PUT result for #{url}:\n#{inspect(result)}" end)

    case result do
      {:ok, http_status, _headers, client_ref} when http_status < 400 ->
        {:ok, body} = :hackney.body(client_ref)
        Logger.debug(fn -> "PUT result body for #{url}:\n#{inspect(body)}" end)
        {:ok, body, http_status, client_ref}

      {:ok, 404, _, _} ->
        {:error, :not_found}

      {:ok, http_status, _headers, client_ref} ->
        {:ok, body} = :hackney.body(client_ref)

        Logger.debug(fn -> "PUT not OK. HTTP status #{http_status} body:\n" <> inspect(body) end)

      not_ok ->
        Logger.debug(fn -> "PUT not OK." <> inspect(not_ok) end)
        not_ok
    end
  end

  @impl true
  def delete(rest_of_url, client_config) do
    url = full_url(client_config.scheme, client_config.hostname, rest_of_url)
    Logger.debug(fn -> "DELETE begin url: #{url}" end)
    result = :hackney.request(:delete, url, headers(client_config.api_key), [])
    Logger.debug(fn -> "DELETE result for #{url}:\n#{inspect(result)}" end)

    case result do
      {:ok, http_status, _headers, client_ref} when http_status < 400 ->
        {:ok, body} = :hackney.body(client_ref)
        Logger.debug(fn -> "DELETE result body for #{url}:\n#{inspect(body)}" end)
        {:ok, body, http_status, client_ref}

      {:ok, 404, _, _} ->
        Logger.debug(fn -> "404 error. DELETE result body for #{url}" end)
        {:error, :not_found}

      {:ok, http_status, headers, client_ref} ->
        {:ok, body} = :hackney.body(client_ref)
        Logger.debug(fn -> "Error. DELETE result body for #{url}:\n#{inspect(body)}" end)
        {:error, {body, http_status, headers}}

      not_ok ->
        {:error, not_ok}
    end
  end

  defp headers(api_key) do
    [
      {"content-type", "application/json"},
      {"Apruve-Api-Key", api_key},
      {"Accept", "application/json;revision=#{@api_version}"},
      {"User-Agent", user_agent_string()}
    ]
  end

  @spec user_agent_string() :: String.t()
  defp user_agent_string() do
    "apruve-elixir-hackney/#{apruve_elixir_version()}"
  end

  @spec apruve_elixir_version() :: String.t()
  defp apruve_elixir_version() do
    {:ok, version_charlist} = :application.get_key(:apruve, :vsn)
    List.to_string(version_charlist)
  end

  @spec full_url(String.t(), String.t(), String.t()) :: String.t()
  defp full_url(scheme, hostname, rest_of_url) do
    "#{scheme}://#{hostname}/api/#{@api_version}/#{rest_of_url}"
  end
end
