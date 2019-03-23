defmodule Apruve.InvoiceReturn do
  @moduledoc """
  Module for invoice returns.
  """

  alias __MODULE__
  alias Apruve.ClientConfig
  alias Apruve.Util
  alias Apruve.Invoice

  defstruct [
    :id,
    :invoice_id,
    :amount_cents,
    :currency,
    :uuid,
    :reason,
    :merchant_notes,
    :created_by_id,
    :created_at,
    :updated_at
  ]

  @type t :: %InvoiceReturn{}
  @type invoice_return_id :: String.t()

  @doc """
  Get invoice return by invoice id and return id.
  """
  @spec get_by_invoice_id_and_return_id(
          Invoice.invoice_id(),
          invoice_return_id,
          ClientConfig.t()
        ) :: {:ok, t()} | {:error, any()}
  def get_by_invoice_id_and_return_id(
        invoice_id,
        return_id,
        client_config \\ ClientConfig.from_application_config!()
      ) do
    result =
      with {:ok, body, _, _} <-
             client_config.adapter.get(
               "invoices/#{invoice_id}/invoice_returns/#{return_id}",
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
  Get all invoice returns by invoice.
  """
  @spec all_by_invoice_id(Invoice.invoice_id(), ClientConfig.t()) ::
          {:ok, [t()]} | {:error, any()}
  def all_by_invoice_id(invoice_id, client_config \\ ClientConfig.from_application_config!()) do
    result =
      with {:ok, body, _, _} <-
             client_config.adapter.get(
               "invoices/#{invoice_id}/invoice_returns",
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
  Create invoice return on the Apruve system.

  Note that returns cannot be issued on invoices which have been cancelled or fully refunded.
  """
  @spec create(t(), ClientConfig.t()) :: {:ok, t()} | {:error, any}
  def create(invoice_return, client_config \\ ClientConfig.from_application_config!()) do
    with :ok <- Util.validate_not_nil(invoice_return, [:invoice_id, :reason, :amount_cents]),
         {:ok, json} <- to_json(invoice_return) do
      case client_config.adapter.post("invoice_returns", json, client_config) do
        {:ok, returned_json_string, 201, _} ->
          from_json(returned_json_string)

        {:error, _} = error ->
          error
      end
    end
  end

  @doc """
  InvoiceReturn struct from JSON string.
  """
  @spec from_json(String.t()) :: {:ok, t()} | {:error, :could_not_make_struct_from_json}
  def from_json(json_string) when is_binary(json_string) do
    Util.from_json(json_string, %InvoiceReturn{})
  end

  @doc """
  JSON string from InvoiceReturn struct.
  """
  @spec to_json(%InvoiceReturn{}) :: {:ok, String.t()} | {:error, any()}
  def to_json(%InvoiceReturn{} = invoice_return) do
    Util.to_json(invoice_return)
  end
end
