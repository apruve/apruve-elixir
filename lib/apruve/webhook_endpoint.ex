defmodule Apruve.WebhookEndpoint do
  @moduledoc """
  Module for Apruve webhook endpoints.

  More information available at https://docs.apruve.com/v4.0/reference#webhookendpoints
  """

  alias __MODULE__
  alias Apruve.ClientConfig
  alias Apruve.Util
  alias Apruve.Merchant

  defstruct [
    :id,
    :merchant_id,
    :version,
    :url
  ]

  @type webhook_endpoint_id :: String.t()
  @type t :: %WebhookEndpoint{}

  @doc """
  Get all webhook endpoints belonging to a merchant. By merchant id.
  """
  @spec all_by_merchant_id(Merchant.merchant_id(), ClientConfig.t() | :from_app_config) ::
          {:ok, [t()]} | {:error, any}
  def all_by_merchant_id(merchant_id, p_client_config \\ :from_app_config) do
    with {:ok, client_config} <- Util.get_client_config(p_client_config),
         {:ok, body, _, _} <-
           client_config.adapter.get("merchants/#{merchant_id}/webhook_endpoints", client_config),
         {:ok, struct_list} <- from_json(body) do
      {:ok, struct_list}
    end
  end

  @doc """
  Get a single webhook endpoint by merchant id and webhook endpoint id.
  """
  @spec get(Merchant.merchant_id(), webhook_endpoint_id, ClientConfig.t() | :from_app_config) ::
          {:ok, t()} | {:error, any()}
  def get(merchant_id, webhook_endpoint_id, p_client_config \\ :from_app_config) do
    parsed_result =
      with {:ok, client_config} <- Util.get_client_config(p_client_config),
           {:ok, body, _, _} <-
             client_config.adapter.get(
               "merchants/#{merchant_id}/webhook_endpoints/#{webhook_endpoint_id}",
               client_config
             ),
           {:ok, struct} <- from_json(body) do
        {:ok, struct}
      end

    case parsed_result do
      {:ok, %WebhookEndpoint{}} ->
        parsed_result

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Create a new webhook endpoint.

  `version` should be "v4"
  """
  @spec create(t(), ClientConfig.t() | :from_app_config) :: {:ok, t()} | {:error, any}
  def create(webhook_endpoint, p_client_config \\ :from_app_config) do
    with :ok <- Util.validate_not_nil(webhook_endpoint, [:merchant_id, :url, :version]),
         {:ok, client_config} <- Util.get_client_config(p_client_config),
         {:ok, json} <- to_json(webhook_endpoint) do
      case client_config.adapter.post(
             "merchants/#{webhook_endpoint.merchant_id}/webhook_endpoints",
             json,
             client_config
           ) do
        {:ok, returned_json_string, 201, _} ->
          from_json(returned_json_string)

        {:error, _} = error ->
          error
      end
    end
  end

  @doc """
  Delete a webhook endpoint by merchant id and webhook endpoint id.
  """
  @spec delete(Merchant.merchant_id(), webhook_endpoint_id, ClientConfig.t() | :from_app_config) ::
          :ok | {:error, any}
  def delete(merchant_id, webhook_endpoint_id, p_client_config \\ :from_app_config) do
    with {:ok, client_config} <- Util.get_client_config(p_client_config) do
      case client_config.adapter.delete(
             "merchants/#{merchant_id}/webhook_endpoints/#{webhook_endpoint_id}",
             client_config
           ) do
        {:ok, _returned_json_string, _, _} ->
          :ok

        {:error, _} = error ->
          error
      end
    end
  end

  @doc """
  JSON string from WebhookEndpoint struct.
  """
  @spec to_json(%WebhookEndpoint{}) :: {:ok, String.t()} | {:error, any()}
  def to_json(%WebhookEndpoint{} = webhook_endpoint) do
    Util.to_json(webhook_endpoint)
  end

  @doc """
  WebhookEndpoint struct from JSON string.
  """
  @spec from_json(String.t()) :: {:ok, t()} | {:error, :could_not_make_struct_from_json}
  def from_json(json_string) when is_binary(json_string) do
    Util.from_json(json_string, %WebhookEndpoint{})
  end
end
