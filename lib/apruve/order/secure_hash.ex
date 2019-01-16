defmodule Apruve.Order.SecureHash do
  alias Apruve.Order

  @moduledoc false

  # Helper module for calculating the Order secure hash.

  @doc """
  Calculates the secure hash.

  See https://docs.apruve.com/docs/merchant-integration-tutorial-1 for more details.
  """
  @spec secure_hash_for_order_and_api_key(Order.t(), String.t()) :: String.t()
  def secure_hash_for_order_and_api_key(order, api_key)
      when is_map(order) and is_binary(api_key) do
    value_string_for_hash(order, api_key)
    |> sha256_hash
  end

  @doc """
  Returns the unhashed string needed for the Apruve secure hash.

  See also `secure_hash_for_order_and_api_key/2`
  """
  @spec value_string_for_hash(Order.t(), String.t()) :: String.t()
  def value_string_for_hash(order, api_key) when is_map(order) and is_binary(api_key) do
    string_for_order_values =
      "#{order.merchant_id}#{order.merchant_order_id}#{order.amount_cents}#{order.currency}#{
        order.tax_cents
      }#{order.shipping_cents}#{order.expire_at}#{order.accepts_payment_terms}#{
        order.finalize_on_create
      }#{order.invoice_on_create}"

    strings_for_items =
      order.order_items
      |> Enum.map(fn item ->
        "#{item.title}#{item.price_total_cents}#{item.price_ea_cents}" <>
          "#{item.quantity}#{item.merchant_notes}#{item.description}#{item.variant_info}#{
            item.sku
          }" <> "#{item.vendor}#{item.view_product_url}"
      end)

    strings_for_items_concatenated = strings_for_items |> Enum.join("")
    api_key <> string_for_order_values <> strings_for_items_concatenated
  end

  # SHA256 hash as expected by Apruve
  @spec sha256_hash(String.t()) :: String.t()
  defp sha256_hash(string) when is_binary(string) do
    :crypto.hash(:sha256, string) |> Base.encode16() |> String.downcase()
  end
end
