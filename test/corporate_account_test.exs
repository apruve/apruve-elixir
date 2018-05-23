defmodule Apruve.CorporateAccountTest do
  defmodule TestAdapter do
    @spec get(String.t(), Apruve.ClientConfig.t()) ::
            {:ok, String.t(), Apruve.Adapter.http_status_code(), any} | {:error, any}
    def get("merchants/foo-merchant-id/corporate_accounts?email=bar-email", _client_config) do
      {:ok, File.read!("test/fixtures/corporate_accounts_response.json"), 200, nil}
    end
  end

  use ExUnit.Case
  doctest Apruve.CorporateAccount

  test "get corporate account" do
    client_config = %Apruve.ClientConfig{adapter: TestAdapter}

    assert Apruve.CorporateAccount.get_by_merchant_id_and_email(
             "foo-merchant-id",
             "bar-email",
             client_config
           ) ==
             {:ok,
              %Apruve.CorporateAccount{
                authorized_buyers: [
                  %{
                    "email" => "0a9s8d6f09as7d8f@mailinator.com",
                    "id" => "ea336fc1ef7bcc243499b70923a6c855",
                    "name" => "Uch'nak Fett"
                  }
                ],
                created_at: nil,
                credit_amount_cents: 2_999_800,
                credit_available_cents: 2_999_800,
                credit_balance_cents: 0,
                creditor_term_id: nil,
                customer_uuid: "ea336fc1ef7bcc243499b70923a6c855",
                disabled_at: nil,
                id: "9bfec2c6b268483761f6cf6cf2378e97",
                merchant_uuid: "5eec7de082331a1c84b8a9be26415e24",
                name: "Death Star Supply Co",
                payment_method_id: nil,
                payment_term_strategy_name: "EOMNet15",
                status: nil,
                trusted_merchant: nil,
                type: "CorporateAccount",
                updated_at: nil
              }}
  end
end
