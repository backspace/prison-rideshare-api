defmodule PrisonRideshare.ExtractGasPrice do
  def extract_gas_price(parsed_json) do
    object = hd(parsed_json)

    price =
      object["pageFunctionResult"]
      |> String.to_float()

    fetched_at =
      object["requestedAt"]
      |> Timex.parse!("{ISO:Extended}")

    %{
      price: price,
      fetched_at: fetched_at
    }
  end
end
