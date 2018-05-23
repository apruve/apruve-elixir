defmodule Apruve.InvoiceTest do
  use ExUnit.Case
  alias Apruve.Invoice
  doctest Apruve.Invoice

  defmodule TestAdapter do
    def post(
          "invoices",
          "{\"amount_cents\":100,\"amount_due\":null,\"created_at\":null,\"currency\":null,\"due_at\":null,\"final_state_at\":null,\"id\":null,\"invoice_items\":[{\"description\":\"desc\",\"price_ea_cents\":100,\"price_total_cents\":100,\"quantity\":1,\"sku\":null,\"title\":\"foo\",\"variant_info\":null,\"vendor\":\"some vendor\",\"view_product_url\":\"https://example.com/\"}],\"issue_on_create\":false,\"issued_at\":null,\"links\":null,\"merchant_invoice_id\":null,\"merchant_notes\":null,\"opened_at\":null,\"order_id\":\"672ea1ede7b991935520883b30ee4ac5\",\"payments\":null,\"shipping_cents\":null,\"status\":null,\"tax_cents\":null}",
          _
        ) do
      {:ok, File.read!("test/fixtures/invoice_post_response.json"), 201, nil}
    end
  end

  test "create invoice" do
    invoice = %Invoice{
      amount_cents: 100,
      invoice_items: [
        %Apruve.InvoiceItem{
          description: "desc",
          price_ea_cents: 100,
          price_total_cents: 100,
          quantity: 1,
          title: "foo",
          vendor: "some vendor",
          view_product_url: "https://example.com/"
        }
      ],
      issue_on_create: false,
      order_id: "672ea1ede7b991935520883b30ee4ac5"
    }

    assert Apruve.Invoice.create(invoice, test_config()) ==
             {:ok,
              %Apruve.Invoice{
                amount_cents: 100,
                amount_due: 100,
                created_at: "2018-05-28T15:19:59-05:00",
                currency: "USD",
                due_at: nil,
                final_state_at: nil,
                id: "e2311678dccd78c1daa19134e7fc9a75",
                invoice_items: [
                  %Apruve.InvoiceItem{
                    description: "desc",
                    price_ea_cents: 100,
                    price_total_cents: 100,
                    quantity: 1,
                    sku: nil,
                    title: "foo",
                    variant_info: nil,
                    vendor: "some vendor",
                    view_product_url: nil
                  }
                ],
                issue_on_create: false,
                issued_at: nil,
                links: %{
                  "order" =>
                    "https://test.apruve.com/api/v4/orders/572ea1ede7b991935520883b30ee4ac5",
                  "self" =>
                    "https://test.apruve.com/api/v4/invoices/f2311578dccd78c1dda19134e7fc9a75"
                },
                merchant_invoice_id: nil,
                merchant_notes: nil,
                opened_at: nil,
                order_id: "672ea1ede7b991935520883b30ee4ac5",
                payments: [],
                shipping_cents: nil,
                status: "pending",
                tax_cents: nil
              }}
  end

  def test_config() do
    %Apruve.ClientConfig{adapter: TestAdapter}
  end
end
