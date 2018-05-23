defmodule Apruve.WebhookEndpointTest do
  use ExUnit.Case
  alias Apruve.WebhookEndpoint
  doctest Apruve.WebhookEndpoint

  defmodule TestAdapter do
    def post(
          "merchants/5eec7de082331a1c84b8a9be26415e24/webhook_endpoints",
          "{\"id\":null,\"merchant_id\":\"5eec7de082331a1c84b8a9be26415e24\",\"url\":\"https://example.com/test\",\"version\":\"v4\"}",
          _
        ) do
      {:ok,
       "{\"id\":\"c60c867d259a40e05810a73e66b90d4f\",\"version\":\"v4\",\"url\":\"https://example.com/test\"}",
       201, nil}
    end
  end

  test "create webhook endpoint" do
    client_config = %Apruve.ClientConfig{adapter: TestAdapter}

    webhook_endpoint = %WebhookEndpoint{
      merchant_id: "5eec7de082331a1c84b8a9be26415e24",
      url: "https://example.com/test",
      version: "v4"
    }

    assert Apruve.WebhookEndpoint.create(webhook_endpoint, client_config) ==
             {:ok,
              %Apruve.WebhookEndpoint{
                id: "c60c867d259a40e05810a73e66b90d4f",
                merchant_id: nil,
                url: "https://example.com/test",
                version: "v4"
              }}
  end

  def test_config() do
    %Apruve.ClientConfig{adapter: TestAdapter}
  end
end
