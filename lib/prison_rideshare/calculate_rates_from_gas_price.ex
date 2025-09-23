defmodule PrisonRideshare.CalculateRatesFromGasPrice do
  def far_rate(gas_price) do
    rate_money =
      Money.multiply(gas_price.price, 17.5)
      |> Money.add(2.4)

    (rate_money.amount / 100)
    |> round
  end

  def close_rate(gas_price) do
    far_rate(gas_price) + 5
  end
end
