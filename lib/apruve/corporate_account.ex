defmodule Apruve.CorporateAccount do
  @moduledoc """
  Module for corporate accounts.
  """

  alias __MODULE__
  alias Apruve.ClientConfig
  alias Apruve.Util
  alias Apruve.Merchant

  defstruct [
    :id,
    :merchant_uuid,
    :customer_uuid,
    :type,
    :created_at,
    :updated_at,
    :payment_term_strategy_name,
    :disabled_at,
    :name,
    :creditor_term_id,
    :payment_method_id,
    :status,
    :trusted_merchant,
    :authorized_buyers,
    :credit_available_cents,
    :credit_balance_cents,
    :credit_amount_cents
  ]

  @type t :: %CorporateAccount{}
  @type email_address :: String.t()

  @doc """
  Get a `CorporateAccount` struct by providing a merchant_id and an email address.
  """
  @spec get_by_merchant_id_and_email(Merchant.merchant_id(), email_address, ClientConfig.t()) ::
          {:ok, t()} | {:error, any()}
  def get_by_merchant_id_and_email(
        merchant_id,
        email,
        client_config \\ ClientConfig.from_application_config!()
      ) do
    result =
      with {:ok, body, _, _} <-
             client_config.adapter.get(
               "merchants/#{merchant_id}/corporate_accounts?email=#{email}",
               client_config
             ),
           {:ok, struct} <- from_json(body) do
        {:ok, struct}
      end

    case result do
      {:ok, list} when is_list(list) ->
        {:ok, List.first(list)}

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Get a Merchant struct by merchant id.
  """
  @spec all_by_merchant_id(Merchant.merchant_id(), ClientConfig.t()) ::
          {:ok, [t()]} | {:error, any()}
  def all_by_merchant_id(merchant_id, client_config \\ ClientConfig.from_application_config!()) do
    result =
      with {:ok, body, _, _} <-
             client_config.adapter.get(
               "merchants/#{merchant_id}/corporate_accounts",
               client_config
             ),
           {:ok, struct} <- from_json(body) do
        {:ok, struct}
      end

    case result do
      {:ok, _} ->
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
    case Util.from_json(json_string, %CorporateAccount{}) do
      {:ok, corporate_account} ->
        {:ok, corporate_account}

      not_ok ->
        not_ok
    end
  end
end
