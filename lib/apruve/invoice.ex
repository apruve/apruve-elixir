defmodule Apruve.Invoice do
  @moduledoc """
  Module for Apruve invoices.
  """

  alias __MODULE__
  alias Apruve.ClientConfig
  alias Apruve.Util

  defstruct [
    :id,
    :order_id,
    :status,
    :amount_cents,
    :currency,
    :merchant_notes,
    :merchant_invoice_id,
    :shipping_cents,
    :tax_cents,
    :invoice_items,
    :payments,
    :created_at,
    :opened_at,
    :due_at,
    :final_state_at,
    :issue_on_create,
    :links,
    :issued_at,
    :amount_due
  ]

  @type invoice_id :: String.t()
  @type t :: %Invoice{}

  @doc """
  Get an invoice by invoice id.
  """
  @spec get(invoice_id, ClientConfig.t()) :: {:ok, t()} | {:error, any()}
  def get(invoice_id, client_config \\ ClientConfig.from_application_config!()) do
    parsed_result =
      with {:ok, body, _, _} <-
             client_config.adapter.get("invoices/#{invoice_id}", client_config),
           {:ok, invoice_struct} <- from_json(body) do
        {:ok, invoice_struct}
      end

    case parsed_result do
      {:ok, %{"errors" => errors}} ->
        {:error, errors}

      {:ok, %Invoice{}} ->
        parsed_result

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Get all invoices belonging to a certain order.
  """
  @spec all_by_order_id(String.t(), ClientConfig.t()) ::
          {:ok, [t()]} | {:error, any}
  def all_by_order_id(order_id, client_config \\ ClientConfig.from_application_config!()) do
    with {:ok, body, _, _} <-
           client_config.adapter.get("orders/#{order_id}/invoices", client_config),
         {:ok, invoice_struct_list} <- from_json(body) do
      {:ok, invoice_struct_list}
    end
  end

  @doc """
  Create invoice on the Apruve system.

  The `invoice_items` field of the `%Apruve.Invoice{}` struct should be a list of
  `%Apruve.InvoiceItem{}`.
  """
  @spec create(t(), ClientConfig.t()) :: {:ok, t()} | {:error, any}
  def create(invoice, client_config \\ ClientConfig.from_application_config!()) do
    with :ok <-
           Util.validate_not_nil(invoice, [
             :order_id,
             :amount_cents,
             :invoice_items,
             :issue_on_create
           ]),
         {:ok, invoice_json} <- to_json(invoice) do
      case client_config.adapter.post("invoices", invoice_json, client_config) do
        {:ok, returned_json_string, 201, _} ->
          from_json(returned_json_string)

        {:error, _} = error ->
          error
      end
    end
  end

  @doc """
  Issue an already existing invoice.
  """
  @spec issue(invoice_id, ClientConfig.t()) :: {:ok, t()} | {:error, any}
  def issue(invoice_id, client_config \\ ClientConfig.from_application_config!())
      when is_binary(invoice_id) do
    post_action_to_invoice("issue", invoice_id, client_config)
  end

  @doc """
  Close an invoice.
  """
  @spec close(invoice_id, ClientConfig.t()) :: {:ok, t()} | {:error, any}
  def close(invoice_id, client_config \\ ClientConfig.from_application_config!())
      when is_binary(invoice_id) do
    post_action_to_invoice("close", invoice_id, client_config)
  end

  @doc """
  Cancel an invoice.
  """
  @spec cancel(invoice_id, ClientConfig.t()) :: {:ok, t()} | {:error, any}
  def cancel(invoice_id, client_config \\ ClientConfig.from_application_config!())
      when is_binary(invoice_id) do
    post_action_to_invoice("cancel", invoice_id, client_config)
  end

  @spec post_action_to_invoice(String.t(), invoice_id, ClientConfig.t()) ::
          {:ok, t()} | {:error, any}
  defp post_action_to_invoice(action, invoice_id, client_config)
       when is_binary(invoice_id) and is_binary(action) do
    case client_config.adapter.post("invoices/#{invoice_id}/#{action}", "", client_config) do
      {:ok, returned_json_string, 200, _} ->
        from_json(returned_json_string)

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Update an invoice on the Apruve system.
  """
  @spec update(t, ClientConfig.t()) :: {:ok, t()} | {:error, any}
  def update(invoice, client_config \\ ClientConfig.from_application_config!()) do
    with {:ok, invoice_json} <- to_json(invoice) do
      case client_config.adapter.put("invoices", invoice_json, client_config) do
        {:ok, returned_json_string, _, _} ->
          from_json(returned_json_string)

        {:error, _} = error ->
          error
      end
    end
  end

  @doc """
  JSON string from Invoice struct.
  """
  @spec to_json(%Invoice{}) :: {:ok, String.t()} | {:error, any()}
  def to_json(%Invoice{} = invoice) do
    Util.to_json(%{invoice | invoice_items: Util.maps_from_struct_list(invoice.invoice_items)})
  end

  @doc """
  Invoice struct from JSON string.
  """
  @spec from_json(String.t()) :: {:ok, Invoice.t()} | {:error, :could_not_make_struct_from_json}
  def from_json(json_string) when is_binary(json_string) do
    case Util.from_json(json_string, %Invoice{}) do
      {:ok, invoices} when is_list(invoices) ->
        invoices_with_items =
          Enum.map(invoices, fn invoice ->
            {:ok, invoice_with_items} =
              make_invoice_items_in_invoice_struct_invoice_item_structs(invoice)

            invoice_with_items
          end)

        {:ok, invoices_with_items}

      {:ok, invoice} ->
        make_invoice_items_in_invoice_struct_invoice_item_structs(invoice)

      not_ok ->
        not_ok
    end
  end

  @spec make_invoice_items_in_invoice_struct_invoice_item_structs(t()) :: {:ok, t()}
  defp make_invoice_items_in_invoice_struct_invoice_item_structs(invoice) do
    parsed_invoice_items = invoice.invoice_items |> Apruve.InvoiceItem.from_parsed_json()
    invoice_with_invoice_items = %{invoice | invoice_items: parsed_invoice_items}
    {:ok, invoice_with_invoice_items}
  end
end
