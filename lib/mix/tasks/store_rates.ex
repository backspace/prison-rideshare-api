defmodule Mix.Tasks.StoreRates do
  use Mix.Task

  @shortdoc "Store ride rates"

  alias PrisonRideshare.Repo
  alias PrisonRideshareWeb.{GasPrice, Ride}
  alias PrisonRideshare.CalculateRatesFromGasPrice

  alias Timex.Duration

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
      window_before_ride_start = Timex.subtract(ride.start, Duration.from_days(1))

      window_after_ride_start = Timex.add(ride.start, Duration.from_days(1))

      closest_gas_price =
        Enum.find(gas_prices, fn gas_price ->
          Timex.after?(gas_price.inserted_at, window_before_ride_start) &&
            Timex.before?(gas_price.inserted_at, window_after_ride_start)
        end)

      if closest_gas_price do
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
