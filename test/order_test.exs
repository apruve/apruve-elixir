defmodule Apruve.OrderTest do
  use ExUnit.Case
  doctest Apruve.Order

  @test_api_key "d9286247a5adff4159de1ac6ee440c0d"

  defmodule TestAdapter do
    @spec get(String.t(), Apruve.ClientConfig.t()) ::
            {:ok, String.t(), Apruve.Adapter.http_status_code(), any} | {:error, any}
    def get("orders/719101ae45b8fab4fb542ed65b455635", _client_config) do
      {:ok, File.read!("test/fixtures/order.json"), 200, nil}
    end

    def post(
          "orders",
          "{\"accepts_payment_terms\":false,\"accepts_payments_via\":null,\"amount_cents\":200,\"created_at\":null,\"currency\":\"USD\",\"default_payment_method\":null,\"expire_at\":\"2018-07-07T23:59:59-05:00\",\"final_state_at\":null,\"finalize_on_create\":true,\"id\":null,\"invoice_on_create\":true,\"links\":null,\"merchant_id\":\"5eec7de082331a1c84b8a9be26415e24\",\"merchant_order_id\":null,\"order_items\":[{\"currency\":\"USD\",\"description\":null,\"id\":\"319101ae4cb8fab4fb542bd65b455635\",\"links\":null,\"merchant_notes\":null,\"price_ea_cents\":200,\"price_total_cents\":200,\"quantity\":null,\"sku\":null,\"title\":\"some widget\",\"variant_info\":null,\"vendor\":null,\"view_product_url\":null}],\"payment_term\":{\"corporate_account_id\":\"b26e8714fa025df0bb7a9500c4b851b4\"},\"payment_terms\":null,\"secure_hash\":null,\"shipping_cents\":500,\"shopper_id\":\"1f3ae8fdd2cf3463b8078e1801463e0c\",\"status\":\"pending\",\"tax_cents\":null,\"updated_at\":null}",
          _
        ) do
      {:ok, File.read!("test/fixtures/order_post_response.json"), 201, nil}
    end
  end

  test "get order" do
    client_config = %Apruve.ClientConfig{adapter: TestAdapter}

    assert Apruve.Order.get("719101ae45b8fab4fb542ed65b455635", client_config) ==
             {:ok,
              %Apruve.Order{
                accepts_payment_terms: false,
                accepts_payments_via: nil,
                amount_cents: 200,
                created_at: "2018-05-23T14:10:28-05:00",
                currency: "USD",
                default_payment_method: nil,
                expire_at: "2018-07-07T23:59:59-05:00",
                final_state_at: nil,
                finalize_on_create: true,
                id: "02b263350ba2a8f59b0d6e00645cc251",
                invoice_on_create: true,
                links: %{
                  "customer" => "https://test.apruve.com/api/v4/users/637.json",
                  "invoices" =>
                    "https://test.apruve.com/api/v4/orders/02b263350ba2a8f59b0d6e00645cc251/invoices.json",
                  "merchant" =>
                    "https://test.apruve.com/api/v4/merchants/5eec7de082331a1c84b8a9be26415e24.json",
                  "self" =>
                    "https://test.apruve.com/api/v4/orders/02b263350ba2a8f59b0d6e00645cc251.json",
                  "shopper" =>
                    "https://test.apruve.com/api/v4/users/1f3ae8fdd2cf3463b8078e1801463e0c.json"
                },
                merchant_id: "5eec7de082331a1c84b8a9be26415e24",
                merchant_order_id: nil,
                order_items: [
                  %Apruve.OrderItem{
                    currency: "USD",
                    description: nil,
                    id: "319101ae4cb8fab4fb542bd65b455635",
                    links: %{
                      "order" =>
                        "https://test.apruve.com/api/v4/orders/02b263350ba2a8f59b0d6e00645cc251.json",
                      "self" =>
                        "https://test.apruve.com/api/v4/order_items/319101ae4cb8fab4fb542bd65b455635.json"
                    },
                    merchant_notes: nil,
                    price_ea_cents: 200,
                    price_total_cents: 200,
                    quantity: nil,
                    sku: nil,
                    title: "some widget",
                    variant_info: nil,
                    vendor: nil,
                    view_product_url: nil
                  }
                ],
                payment_term: nil,
                payment_terms: %{
                  "escalated_at" => "2018-05-23T14:10:28-05:00",
                  "final_state_at" => "2018-05-23T14:10:28-05:00",
                  "links" => %{
                    "order" =>
                      "https://test.apruve.com/api/v4/orders/02b263350ba2a8f59b0d6e00645cc251.json"
                  },
                  "merchant_order_id" => nil,
                  "po_number" => nil,
                  "purchase_order_id" => "02b263350ba2a8f59b0d6e00645cc251",
                  "status" => "accepted",
                  "type" => "CorporateAccount"
                },
                secure_hash: nil,
                shipping_cents: 500,
                shopper_id: "1f3ae8fdd2cf3463b8078e1801463e0c",
                status: "pending",
                tax_cents: 0,
                updated_at: nil
              }}
  end

  test "create order" do
    client_config = %Apruve.ClientConfig{adapter: TestAdapter}

    order = %Apruve.Order{
      accepts_payment_terms: false,
      amount_cents: 200,
      currency: "USD",
      expire_at: "2018-07-07T23:59:59-05:00",
      finalize_on_create: true,
      invoice_on_create: true,
      merchant_id: "5eec7de082331a1c84b8a9be26415e24",
      order_items: [
        %Apruve.OrderItem{
          currency: "USD",
          id: "319101ae4cb8fab4fb542bd65b455635",
          price_ea_cents: 200,
          price_total_cents: 200,
          title: "some widget"
        }
      ],
      payment_term: %{corporate_account_id: "b26e8714fa025df0bb7a9500c4b851b4"},
      shipping_cents: 500,
      shopper_id: "1f3ae8fdd2cf3463b8078e1801463e0c",
      status: "pending"
    }

    assert Apruve.Order.create(order, client_config) ==
             {:ok,
              %Apruve.Order{
                accepts_payment_terms: false,
                accepts_payments_via: nil,
                amount_cents: 200,
                created_at: "2018-05-23T20:44:05-05:00",
                currency: "USD",
                default_payment_method: nil,
                expire_at: "2018-07-07T23:59:59-05:00",
                final_state_at: nil,
                finalize_on_create: true,
                id: "719101ae45b8fab4fb542ed65b455635",
                invoice_on_create: true,
                links: %{
                  "customer" => "https://test.apruve.com/api/v4/users/637.json",
                  "invoices" =>
                    "https://test.apruve.com/api/v4/orders/7b05d2915d805f2ddfb7a878bdd15411/invoices.json",
                  "merchant" =>
                    "https://test.apruve.com/api/v4/merchants/5eec7de082331a1c84b8a9be26415e24.json",
                  "self" =>
                    "https://test.apruve.com/api/v4/orders/7b05d2915d805f2ddfb7a878bdd15411.json",
                  "shopper" =>
                    "https://test.apruve.com/api/v4/users/1f3ae8fdd2cf3463b8078e1801463e0c.json"
                },
                merchant_id: "5eec7de082331a1c84b8a9be26415e24",
                merchant_order_id: nil,
                order_items: [
                  %Apruve.OrderItem{
                    currency: "USD",
                    description: nil,
                    id: "73c8d0b70feac236e95b2baffe52a3ac",
                    links: %{
                      "order" =>
                        "https://test.apruve.com/api/v4/orders/7b05d2915d805f2ddfb7a878bdd15411.json",
                      "self" =>
                        "https://test.apruve.com/api/v4/order_items/73c8d0b70feac236e95b2baffe52a3ac.json"
                    },
                    merchant_notes: nil,
                    price_ea_cents: 200,
                    price_total_cents: 200,
                    quantity: nil,
                    sku: nil,
                    title: "some widget",
                    variant_info: nil,
                    vendor: nil,
                    view_product_url: nil
                  }
                ],
                payment_term: nil,
                payment_terms: %{
                  "escalated_at" => "2018-05-23T20:44:05-05:00",
                  "final_state_at" => "2018-05-23T20:44:05-05:00",
                  "links" => %{
                    "order" =>
                      "https://test.apruve.com/api/v4/orders/7b05d2915d805f2ddfb7a878bdd15411.json"
                  },
                  "merchant_order_id" => nil,
                  "po_number" => nil,
                  "purchase_order_id" => "7b05d2915d805f2ddfb7a878bdd15411",
                  "status" => "accepted",
                  "type" => "CorporateAccount"
                },
                secure_hash: nil,
                shipping_cents: 500,
                shopper_id: "1f3ae8fdd2cf3463b8078e1801463e0c",
                status: "pending",
                tax_cents: 0,
                updated_at: nil
              }}
  end

  test "value_string_for_hash" do
    order = %Apruve.Order{
      id: "foo",
      amount_cents: 1000,
      order_items: [%Apruve.OrderItem{title: "an order item", sku: "ansku"}]
    }

    assert Apruve.Order.SecureHash.value_string_for_hash(order, "") == "1000an order itemansku"
  end

  test "secure hash" do
    order = %Apruve.Order{
      id: "foo",
      amount_cents: 1000,
      order_items: [%Apruve.OrderItem{title: "an order item", sku: "ansku"}]
    }

    api_key = "anapikey3"

    assert Apruve.Order.secure_hash_for_order_and_api_key(order, api_key) ==
             "cbc8e82c67bfbff8d91822b1a60486a269da0c5126d64095408f79d0d3719501"
  end

  test "secure hash2" do
    order = %Apruve.Order{
      merchant_id: "4d556524255a8e65385f9da2a2693cf1",
      merchant_order_id: "WidgetCo-001",
      amount_cents: 1150,
      currency: "USD",
      tax_cents: 50,
      shipping_cents: 100,
      expire_at: "2014-07-15T10:12:27-05:00",
      order_items: [
        %Apruve.OrderItem{
          description: "Description for a widget",
          title: "A Widget",
          sku: "SKU-ABCD",
          # this one didn't match https://docs.apruve.com/docs/merchant-integration-tutorial-1 changed from 900 to 1000. Also the key name is changed
          price_ea_cents: 1000,
          quantity: 1
        },
        %Apruve.OrderItem{
          description: "Description for another widget",
          title: "Another Widget",
          sku: "SKU-EFGH",
          # this one didn't match https://docs.apruve.com/docs/merchant-integration-tutorial-1 changed from 100 to 150
          price_ea_cents: 150,
          quantity: 1
        }
      ]
    }

    api_key = @test_api_key

    assert Apruve.Order.SecureHash.value_string_for_hash(order, api_key) ==
             "d9286247a5adff4159de1ac6ee440c0d4d556524255a8e65385f9da2a2693cf1WidgetCo-0011150USD501002014-07-15T10:12:27-05:00A Widget10001Description for a widgetSKU-ABCDAnother Widget1501Description for another widgetSKU-EFGH"

    assert Apruve.Order.secure_hash_for_order_and_api_key(order, api_key) ==
             "61ce58ff0c1dbd2b50d241fcc8ea4c9baa9e9248b7eefda9e527e076aacb6136"

    assert Apruve.Order.secure_hash_for_order_and_api_key(order, test_config()) ==
             "61ce58ff0c1dbd2b50d241fcc8ea4c9baa9e9248b7eefda9e527e076aacb6136"
  end

  def test_config() do
    %Apruve.ClientConfig{adapter: TestAdapter, api_key: @test_api_key}
  end
end
