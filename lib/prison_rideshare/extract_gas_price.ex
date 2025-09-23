defmodule PrisonRideshare.ExtractGasPrice do
  def extract_gas_price(parsed_json) do
    with true <- is_list(parsed_json),
         [object | _] <- parsed_json,
         true <- is_map(object),
         value when not is_nil(value) <- Map.get(object, "pageFunctionResult"),
         {:ok, price} <- coerce_to_float(value) do
      {:ok, %{price: price}}
    else
      false -> {:error, :invalid_format}
      [] -> {:error, :invalid_format}
      nil -> {:error, :missing_value}
      {:error, reason} -> {:error, reason}
    end
  end

  defp coerce_to_float(value) when is_binary(value) do
    case Float.parse(value) do
      {num, ""} -> {:ok, num}
      _ -> {:error, :invalid_number}
    end
  end

  defp coerce_to_float(value) when is_number(value) do
    {:ok, value * 1.0}
  end

  defp coerce_to_float(_), do: {:error, :invalid_number}
end
