defmodule Apruve.Util do
  @moduledoc false

  @spec to_json(map()) :: {:ok, String.t()} | {:error, any()}
  def to_json(struct) do
    struct |> Map.from_struct() |> Jason.encode()
  end

  @spec from_json(String.t(), map()) ::
          {:ok, map()} | {:ok, [map()]} | {:error, :could_not_decode_json}
  def from_json(json_string, empty_struct) when is_binary(json_string) do
    case Jason.decode(json_string) do
      {:ok, json_parsed} ->
        keys = empty_struct |> Map.from_struct() |> Map.keys()

        struct =
          case json_parsed do
            json_parsed when is_list(json_parsed) ->
              json_parsed
              |> Enum.map(fn element ->
                struct_from_keys_struct_parsed_json(keys, empty_struct, element)
              end)

            json_parsed ->
              struct_from_keys_struct_parsed_json(keys, empty_struct, json_parsed)
          end

        {:ok, struct}

      _ ->
        {:error, :could_not_decode_json}
    end
  end

  @spec struct_from_keys_struct_parsed_json([atom()], map(), map()) :: map()
  def struct_from_keys_struct_parsed_json(keys, empty_struct, json_parsed) do
    Enum.reduce(keys, empty_struct, fn key, acc_order ->
      Map.put(acc_order, key, json_parsed[Atom.to_string(key)])
    end)
  end

  @doc """
  Converts a list of structs to a list of non-struct maps.
  Returns `nil` if passed `nil`.

  Used for JSON conversion.
  """
  @spec maps_from_struct_list(nil | [map]) :: nil | [map]
  def maps_from_struct_list(nil) do
    nil
  end

  def maps_from_struct_list(struct_list) when is_list(struct_list) do
    struct_list
    |> Enum.map(&Map.from_struct/1)
  end

  @doc false
  @spec validate_not_nil(map(), list) ::
          :ok | {:error, {:the_following_fields_cannot_be_nil, list}}
  def validate_not_nil(map, fields) do
    fields_with_nil =
      Enum.map(fields, fn field -> {field, Map.get(map, field)} end)
      |> Enum.filter(fn {_field_name, value} -> value == nil end)
      |> Enum.map(fn {field_name, _} -> field_name end)

    case fields_with_nil do
      [] ->
        :ok

      list_of_field_names ->
        {:error, {:the_following_fields_cannot_be_nil, list_of_field_names}}
    end
  end
end
