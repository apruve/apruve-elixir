defmodule Apruve.Order do
  @moduledoc """
  Module for Apruve orders.
  """

  @type order_id :: String.t()

  alias __MODULE__
  alias Apruve.ClientConfig
  alias Apruve.Util

  defstruct [
    :id,
    :merchant_id,
    :shopper_id,
    :merchant_order_id,
    :status,
    :amount_cents,
    :currency,
    :tax_cents,
    :shipping_cents,
    :expire_at,
    :order_items,
    :accepts_payments_via,
    :accepts_payment_terms,
    :payment_terms,
    :payment_term,
    :created_at,
    :updated_at,
    :final_state_at,
    :default_payment_method,
    :links,
    :finalize_on_create,
    :invoice_on_create,
    :secure_hash
  ]

  @type t :: %Order{}

  @doc """
  Get an order by the Apruve order id.

      iex> {:ok, order} = Apruve.Order.get("719101ae45b8fab4fb542ed65b455635", test_config())
      iex> order.id
      "02b263350ba2a8f59b0d6e00645cc251"
  """
  @spec get(order_id, ClientConfig.t()) :: {:ok, Order.t()} | {:error, any()}
  def get(order_id, client_config \\ ClientConfig.from_application_config!()) do
    url_part = "orders/#{order_id}"
    adapter = client_config.adapter
    result = adapter.get(url_part, client_config)

    parsed_result =
      with {:ok, body, _status, _adapter_meta} <- result,
           {:ok, order_struct} <- from_json(body) do
        {:ok, order_struct}
      end

    case parsed_result do
      {:ok, %Order{}} ->
        parsed_result

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, parsed_result}
    end
  end

  @doc """
  Create an order.
  """
  @spec create(t, ClientConfig.t()) :: {:ok, t} | {:error, any}
  def create(order, client_config \\ ClientConfig.from_application_config!()) do
    with :ok <- validate_order(order),
         {:ok, order_json} <- to_json(order) do
      case client_config.adapter.post("orders", order_json, client_config) do
        {:ok, json, 201, _} ->
          from_json(json)

        not_ok ->
          {:error, not_ok}
      end
    end
  end

  @doc """
  Get all orders. Optionally only ones matching a certain `merchant_order_id`.

  A merchant order id is the order id used by the merchant.

  Results can be limited to the first 25 orders by the server side API.
  """
  @spec all(ClientConfig.t()) :: {:ok, [Order.t()]} | {:error, any()}
  def all(merchant_order_id \\ nil, client_config \\ ClientConfig.from_application_config!()) do
    url_part =
      case merchant_order_id do
        nil ->
          "orders"

        _ ->
          "orders?merchant_order_id=#{merchant_order_id}"
      end

    result = client_config.adapter.get(url_part, client_config)

    parsed_result =
      with {:ok, body, _http_status, _adapter_meta} <- result,
           {:ok, order_struct_list} <- from_json(body) do
        {:ok, order_struct_list}
      end

    case parsed_result do
      {:ok, orders} when is_list(orders) ->
        parsed_result

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, parsed_result}
    end
  end

  @doc """
  Convert a JSON string to an Order struct or list of Order structs.
  """
  @spec from_json(String.t()) ::
          {:ok, t} | {:ok, [t]} | {:error, :could_not_make_struct_from_json}
  def from_json(json_string) when is_binary(json_string) do
    case Util.from_json(json_string, %Order{}) do
      {:ok, orders} when is_list(orders) ->
        orders =
          Enum.map(orders, fn order ->
            {:ok, order_with_items} = make_order_items_in_order_struct_order_item_structs(order)
            order_with_items
          end)

        {:ok, orders}

      {:ok, order} ->
        make_order_items_in_order_struct_order_item_structs(order)

      not_ok ->
        not_ok
    end
  end

  @spec make_order_items_in_order_struct_order_item_structs(Order.t()) :: {:ok, Order.t()}
  defp make_order_items_in_order_struct_order_item_structs(order) do
    parsed_order_items = order.order_items |> Apruve.OrderItem.from_parsed_json()
    order_with_order_items = %{order | order_items: parsed_order_items}
    {:ok, order_with_order_items}
  end

  @doc """
  Convert `Apruve.Order` struct to JSON.
  """
  @spec to_json(%Order{}) :: {:ok, String.t()} | {:error, any()}
  def to_json(%Order{} = order) do
    Util.to_json(%{order | order_items: Util.maps_from_struct_list(order.order_items)})
  end

  @spec validate_order(t) :: :ok | {:error, any}
  defp validate_order(order) do
    with :ok <-
           Util.validate_not_nil(order, [:merchant_id, :shopper_id, :order_items, :payment_term]),
         :ok <- validate_payment_term(order) do
      :ok
    end
  end

  @spec validate_payment_term(t) :: :ok | {:error, :payment_term_corporate_account_id_not_set}
  defp validate_payment_term(%{payment_term: payment_term}) do
    case payment_term do
      %{corporate_account_id: corporate_account_id} when corporate_account_id != nil ->
        :ok

      _ ->
        {:error, :payment_term_corporate_account_id_not_set}
    end
  end

  @doc """
  Calculates the secure hash.

  Takes an order and one of: an API key, an `Apruve.ClientConfig` struct.

  See https://docs.apruve.com/docs/merchant-integration-tutorial-1 for more details.
  """
  @spec secure_hash_for_order_and_api_key(t(), String.t() | ClientConfig.t()) ::
          String.t()
  def secure_hash_for_order_and_api_key(order, api_key_or_conf) when is_binary(api_key_or_conf) do
    __MODULE__.SecureHash.secure_hash_for_order_and_api_key(order, api_key_or_conf)
  end

  def secure_hash_for_order_and_api_key(order, %{api_key: api_key}) do
    __MODULE__.SecureHash.secure_hash_for_order_and_api_key(order, api_key)
  end
end
