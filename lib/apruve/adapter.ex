defmodule Apruve.Adapter do
  @moduledoc """
  Module for specifying adapter behaviours. Typically an HTTPS adapter that makes HTTPS
  requests to Apruve servers.
  """

  alias Apruve.ClientConfig

  @type http_status_code :: non_neg_integer
  @type url_fragment :: String.t()

  @callback get(url_fragment, ClientConfig.t()) ::
              {:ok, String.t(), http_status_code, any} | {:error, any}
  @callback post(url_fragment, String.t(), ClientConfig.t()) ::
              {:ok, String.t(), http_status_code, any} | {:error, any}
  @callback put(url_fragment, String.t(), ClientConfig.t()) ::
              {:ok, String.t(), http_status_code, any} | {:error, any}
  @callback delete(url_fragment, ClientConfig.t()) ::
              {:ok, String.t(), http_status_code, any} | {:error, any}
end
