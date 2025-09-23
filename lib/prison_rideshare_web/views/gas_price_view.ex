defmodule PrisonRideshareWeb.GasPriceView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  alias PrisonRideshare.CalculateRatesFromGasPrice

  attributes([:price, :far_rate, :close_rate, :inserted_at])

  money_amount(:price)

  def far_rate(gas_price, _conn) do
    CalculateRatesFromGasPrice.far_rate(gas_price)
  end

  def close_rate(gas_price, _conn) do
    CalculateRatesFromGasPrice.close_rate(gas_price)
  end
end
