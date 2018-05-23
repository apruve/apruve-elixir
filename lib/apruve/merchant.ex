defmodule Apruve.Merchant do
  @moduledoc """
  Module for Apruve merchants.
  """

  alias __MODULE__
  alias Apruve.ClientConfig
  alias Apruve.Util

  defstruct [:id, :name, :email, :web_url, :phone]

  @type merchant_id :: String.t()
  @type t :: %Merchant{}

  @spec get(merchant_id, ClientConfig.t() | :from_app_config) :: {:ok, t()} | {:error, any()}
  def get(merchant_id, p_client_config \\ :from_app_config) do
    result =
      with {:ok, client_config} <- Util.get_client_config(p_client_config),
           {:ok, body, _, _} <-
             client_config.adapter.get("merchants/#{merchant_id}", client_config),
           {:ok, merchant_struct} <- from_json(body) do
        {:ok, merchant_struct}
      end

    case result do
      {:ok, %Merchant{}} ->
        result

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Merchant struct from JSON string.
  """
  @spec from_json(String.t()) :: {:ok, t()} | {:error, :could_not_make_struct_from_json}
  def from_json(json_string) when is_binary(json_string) do
    case Util.from_json(json_string, %Merchant{}) do
      {:ok, merchant} ->
        {:ok, merchant}

      not_ok ->
        not_ok
    end
  end
end
