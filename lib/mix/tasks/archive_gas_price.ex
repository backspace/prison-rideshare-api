defmodule Mix.Tasks.ArchiveGasPrice do
  use Mix.Task

  @shortdoc "Archive the current gas price"

  alias PrisonRideshare.Repo
  alias PrisonRideshareWeb.GasPrice

  alias PrisonRideshare.ExtractGasPrice

  def run(_) do
    Mix.Task.run("app.start")
    HTTPoison.start()

    response = HTTPoison.get!(Application.get_env(:prison_rideshare, :gas_price_endpoint))

    with {:ok, parsed} <- Poison.decode(response.body),
         result <- ExtractGasPrice.extract_gas_price(parsed) do
      case result do
        {:ok, %{price: price}} ->
          Repo.insert!(GasPrice.changeset(%GasPrice{}, %{price: round(price)}))

        {:error, reason} ->
          PrisonRideshare.Email.archive_gas_price_failure_report(reason)
          |> PrisonRideshare.Mailer.deliver_now()
      end
    else
      {:error, decode_reason} ->
        PrisonRideshare.Email.archive_gas_price_failure_report(
          {:json_decode_error, decode_reason}
        )
        |> PrisonRideshare.Mailer.deliver_now()
    end
  end
end
