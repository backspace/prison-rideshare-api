defmodule Mix.Tasks.StoreRates do
  use Mix.Task

  @shortdoc "Store ride rates"

  alias PrisonRideshare.Repo
  alias PrisonRideshareWeb.{GasPrice, Ride}
  alias PrisonRideshare.CalculateRatesFromGasPrice
  alias PrisonRideshare.Email

  import Ecto.Query

  def run(_) do
    Mix.Task.run("app.start")

    rides =
      Repo.all(
        from(
          r in Ride,
          where:
            r.enabled and is_nil(r.gas_price_id) and (is_nil(r.rate) or r.rate == 0) and
              not is_nil(r.institution_id),
          preload: [:institution]
        )
      )

    gas_prices = Repo.all(GasPrice, order_by: :inserted_at)

    Enum.each(rides, fn ride ->
      # Choose the nearest gas price by proximity to start time

      closest_gas_price =
        case gas_prices do
          [] ->
            nil

          _ ->
            Enum.min_by(gas_prices, fn gp ->
              abs(Timex.diff(gp.inserted_at, ride.start, :seconds))
            end)
        end

      if closest_gas_price do
        # send a warning if the assigned gas price is 5 days or more from the ride start
        diff_seconds =
          Timex.diff(closest_gas_price.inserted_at, ride.start, :seconds)
          |> abs()

        if diff_seconds >= 5 * 24 * 60 * 60 do
          Email.store_rates_gap_warning_report(ride, closest_gas_price)
          |> PrisonRideshare.Mailer.deliver_now()
        end

        rate =
          if ride.institution.far,
            do: CalculateRatesFromGasPrice.far_rate(closest_gas_price),
            else: CalculateRatesFromGasPrice.close_rate(closest_gas_price)

        changeset =
          Ride.changeset(ride, %{
            gas_price_id: closest_gas_price.id,
            rate: rate
          })

        PaperTrail.update!(changeset, origin: "StoreRates")
      end
    end)
  end
end
