defmodule PrisonRideshareWeb.GasPriceController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.GasPrice

  def index(conn, _) do
    gas_prices = Repo.all(GasPrice)

    render(conn, "index.json-api", data: gas_prices)
  end
end
