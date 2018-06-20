defmodule Mix.Tasks.ArchiveGasPrice do
  use Mix.Task

  @shortdoc "Archive the current gas price"

  alias PrisonRideshare.Repo
  alias PrisonRideshareWeb.GasPrice

  alias PrisonRideshare.ExtractGasPrice

  def run(_) do
    HTTPoison.start()

    response = HTTPoison.get!(Application.get_env(:prison_rideshare, :gas_price_endpoint))

    price =
      response.body
      |> Poison.decode!()
      |> ExtractGasPrice.extract_gas_price()

    Repo.insert!(GasPrice.changeset(%GasPrice{}, %{price: round(price.price)}))
  end
end
