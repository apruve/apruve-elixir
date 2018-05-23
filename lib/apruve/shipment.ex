defmodule Apruve.Shipment do
  @moduledoc """
  Module for Apruve shipments.
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
    :shipper,
    :shipped_at,
    :tracking_number,
    :delivered_at,
    :merchant_notes,
    :shipment_items,
    :tax_cents,
    :shipping_cents,
    :status,
    :merchant_shipment_id
  ]

  @type shipment_id :: String.t()
  @type t :: %Shipment{}

  @spec get_by_invoice_id_and_shipment_id(
          Invoice.invoice_id(),
          shipment_id,
          ClientConfig.t() | :from_app_config
        ) :: {:ok, t()} | {:error, any()}
  def get_by_invoice_id_and_shipment_id(
        invoice_id,
        shipment_id,
        p_client_config \\ :from_app_config
      ) do
    parsed_result =
      with {:ok, client_config} <- Util.get_client_config(p_client_config),
           {:ok, body, _, _} <-
             client_config.adapter.get(
               "invoices/#{invoice_id}/shipments/#{shipment_id}",
               client_config
             ),
           {:ok, struct} <- from_json(body) do
        {:ok, struct}
      end

    case parsed_result do
      {:ok, %{"errors" => errors}} ->
        {:error, errors}

      {:ok, %Shipment{}} ->
        parsed_result

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Create shipment on the Apruve system.

  In the Shipment struct:

  `shipped_at` should be set to a `DateTime` struct or an ISO 8601 string. E.g. "2018-01-27T12:48:34Z".
  `status` should be set to "fulfilled" or "partial".
  """
  @spec create(t(), ClientConfig.t() | :from_app_config) :: {:ok, t()} | {:error, any}
  def create(shipment, p_client_config \\ :from_app_config) do
    with :ok <-
           Util.validate_not_nil(shipment, [
             :invoice_id,
             :shipment_items,
             :shipped_at,
             :amount_cents,
             :status
           ]),
         {:ok, client_config} <- Util.get_client_config(p_client_config),
         {:ok, json} <- to_json(shipment) do
      case client_config.adapter.post(
             "invoices/#{shipment.invoice_id}/shipments",
             json,
             client_config
           ) do
        {:ok, returned_json_string, 201, _} ->
          from_json(returned_json_string)

        {:ok, _, _, details} ->
          {:error, details}

        {:error, _} = error ->
          error
      end
    end
  end

  @doc """
  JSON string from Shipment struct.
  """
  @spec to_json(%Shipment{}) :: {:ok, String.t()} | {:error, any()}
  def to_json(%Shipment{} = shipment) do
    Util.to_json(%{shipment | shipment_items: Util.maps_from_struct_list(shipment.shipment_items)})
  end

  @doc """
  Shipment struct from JSON string.
  """
  @spec from_json(String.t()) :: {:ok, t()} | {:error, :could_not_make_struct_from_json}
  def from_json(json_string) when is_binary(json_string) do
    case Util.from_json(json_string, %Shipment{}) do
      {:ok, shipments} when is_list(shipments) ->
        shipments_with_items =
          Enum.map(shipments, fn shipment ->
            {:ok, shipment_with_items} =
              make_shipment_items_in_shipment_struct_shipment_item_structs(shipment)

            shipment_with_items
          end)

        {:ok, shipments_with_items}

      {:ok, shipment} ->
        {:ok, shipment}

      not_ok ->
        not_ok
    end
  end

  @spec make_shipment_items_in_shipment_struct_shipment_item_structs(t()) :: {:ok, t()}
  defp make_shipment_items_in_shipment_struct_shipment_item_structs(shipment) do
    parsed_shipment_items = shipment.shipment_items |> Apruve.ShipmentItem.from_parsed_json()
    shipment_with_shipment_items = %{shipment | shipment_items: parsed_shipment_items}
    {:ok, shipment_with_shipment_items}
  end
end
