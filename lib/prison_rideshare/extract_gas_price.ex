defmodule PrisonRideshare.ExtractGasPrice do
  def extract_gas_price(parsed_json) do
    object = hd(parsed_json)

    price =
      object["pageFunctionResult"]
      |> String.to_float()

    %{
      price: price
    }
  end
end
