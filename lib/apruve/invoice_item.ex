defmodule Apruve.InvoiceItem do
  @moduledoc """
  Module for Apruve invoice items.
  """

  defstruct [
    :title,
    :price_total_cents,
    :price_ea_cents,
    :quantity,
    :description,
    :variant_info,
    :sku,
    :vendor,
    :view_product_url
  ]

  alias __MODULE__

  @spec from_parsed_json([map()]) :: [%InvoiceItem{}]
  def from_parsed_json(json_parsed) do
    keys = %Apruve.InvoiceItem{} |> Map.from_struct() |> Map.keys()

    json_parsed
    |> Enum.map(fn invoice_item_json_parsed ->
      Enum.reduce(keys, %InvoiceItem{}, fn key, acc ->
        Map.put(acc, key, invoice_item_json_parsed[Atom.to_string(key)])
      end)
    end)
  end
end
