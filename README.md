![Apruve logo](https://raw.githubusercontent.com/apruve/apruve-elixir/master/logo.png)

[Documentation is available at hexdocs.pm](https://hexdocs.pm/apruve/)

## Installation

The package can be installed
by adding `apruve` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:apruve, "~> 0.2.0"},
  ]
end
```

## Configuration

All functions that need to do API calls take a `%Apruve.ClientConfig{}` struct.
When this is passed to all the function calls that need it, no other configuration is needed.

Alternatively a global configuration can be set like this:

```elixir
config :apruve,
  client_config: %{
    api_key: "API KEY GOES HERE",
    hostname: "test.apruve.com",
    scheme: "https",
    adapter: Apruve.Adapters.Hackney
  }
```

When this is set, it is not necessary to pass a `%Apruve.ClientConfig{}` struct to the functions. By default, the client configuration is instead read from the app configuration set as described above.

## Examples

### Get an order by order id using the application config
`{:ok, order} = Apruve.Order.get("719101ae45b8fab4fb542ed65b455635")`

### Get an order by order id passing configuration in a struct

Alternatively the client information such as the API key can be passed in a `ClientConfig` struct instead of being read from the configuration:

`{:ok, order} = Apruve.Order.get("719101ae45b8fab4fb542ed65b455635", %Apruve.ClientConfig{adapter: Apruve.Adapters.Hackney, scheme: "https", hostname: "test.apruve.com", api_key: "API KEY GOES HERE"})`

## Datetimes

Datetimes from the Apruve API are returned as ISO 8601 strings with timezone offset. When sending data to the Apruve API, a `DateTime` struct can also be used. For instance the `delivered_at` field of a `Shipment` can be set to a `DateTime`. `DateTime` structs will be converted to strings automatically before being sent to Apruve.
