defmodule Mix.Tasks.StoreRates do
  use Mix.Task

  @shortdoc "Store ride rates"

  alias PrisonRideshare.Repo
  alias PrisonRideshareWeb.{GasPrice, Ride}

  alias Timex.Duration

  import Ecto.Query

  def run(_) do
    Mix.Task.run("app.start")

    rides =
      Repo.all(
        from(
          r in Ride,
          where:
            r.enabled and is_nil(r.gas_price_id) and is_nil(r.rate) and
              not is_nil(r.institution_id),
          preload: [:institution]
        )
      )

    gas_prices = Repo.all(GasPrice, order_by: :inserted_at)

    Enum.each(rides, fn ride ->
      window_before_ride_start =
        Timex.subtract(Ecto.DateTime.to_erl(ride.start), Duration.from_days(1))

      window_after_ride_start = Timex.add(Ecto.DateTime.to_erl(ride.start), Duration.from_days(1))

      closest_gas_price =
        Enum.find(gas_prices, fn gas_price ->
          Timex.after?(gas_price.inserted_at, window_before_ride_start) &&
            Timex.before?(gas_price.inserted_at, window_after_ride_start)
        end)

      if closest_gas_price do
        close_premium = if ride.institution.far, do: 0, else: 5

        rate_money =
          Money.multiply(closest_gas_price.price, 17.5)
          |> Money.add(2.4)

        rate =
          (rate_money.amount / 100)
          |> round

        total = rate + close_premium

        changeset =
          Ride.changeset(ride, %{
            gas_price_id: closest_gas_price.id,
            rate: total
          })

        PaperTrail.update!(changeset, origin: "StoreRates")
      end
    end)
  end
end
