defmodule Apruve.ShipmentItem do
  @moduledoc """
  Module for Apruve shipment items.
  """

  defstruct [
    :title,
    :amount_cents,
    :price_ea_cents,
    :price_total_cents,
    :shipping_cents,
    :tax_cents,
    :quantity,
    :description,
    :variant_info,
    :sku,
    :vendor,
    :currency,
    :view_product_url,
    :price_ea_cents,
    :taxable,
    :shipment_id,
    :uuid
  ]

  alias __MODULE__

  @spec from_parsed_json([map()]) :: [%ShipmentItem{}]
  def from_parsed_json(json_parsed) do
    keys = %Apruve.ShipmentItem{} |> Map.from_struct() |> Map.keys()

    json_parsed
    |> Enum.map(fn shipment_item_json_parsed ->
      Enum.reduce(keys, %ShipmentItem{}, fn key, acc ->
        Map.put(acc, key, shipment_item_json_parsed[Atom.to_string(key)])
      end)
    end)
  end
end
