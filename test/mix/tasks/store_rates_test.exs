defmodule Mix.Tasks.StoreRatesTest do
  use ExUnit.Case
  use PrisonRideshareWeb.ConnCase
  use Bamboo.Test

  alias PrisonRideshare.Repo

  alias PrisonRideshareWeb.{GasPrice, Institution, Ride}

  import Money.Sigils

  defp datetime(date, {hour, minute, second}) do
    {year, month, day} = Date.to_erl(date)

    NaiveDateTime.from_erl!({{year, month, day}, {hour, minute, second}})
  end

  defp reload_ride(ride) do
    Ride
    |> Repo.get!(ride.id)
    |> Repo.preload(:gas_price)
  end

  test "running the rate calculator" do
    today = Date.utc_today()
    yesterday = Date.add(today, -1)
    old_date = Date.add(today, -30)
    ancient_date = Date.add(today, -400)
    ancient_price_date = Date.add(ancient_date, -10)
    tomorrow = Date.add(today, 1)

    yesterday_price =
      Repo.insert!(%GasPrice{
        price: 90,
        inserted_at: datetime(yesterday, {8, 0, 0})
      })

    today_price =
      Repo.insert!(%GasPrice{
        price: 100,
        inserted_at: datetime(today, {16, 37, 0})
      })

    ancient_price =
      Repo.insert!(%GasPrice{
        price: 5,
        inserted_at: datetime(ancient_price_date, {0, 0, 0})
      })

    close_institution =
      Repo.insert!(%Institution{
        name: "Close",
        far: false
      })

    far_institution =
      Repo.insert!(%Institution{
        name: "Far",
        far: true
      })

    ancient_ride =
      Repo.insert!(%Ride{
        start: datetime(ancient_date, {11, 0, 0}),
        institution: close_institution,
        end: datetime(ancient_date, {12, 0, 0}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    old_ride =
      Repo.insert!(%Ride{
        start: datetime(old_date, {11, 0, 0}),
        institution: close_institution,
        end: datetime(old_date, {12, 0, 0}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    yesterday_ride =
      Repo.insert!(%Ride{
        start: datetime(yesterday, {11, 0, 0}),
        institution: close_institution,
        end: datetime(yesterday, {12, 0, 0}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    zero_set_rate_ride =
      Repo.insert!(%Ride{
        start: datetime(yesterday, {11, 0, 1}),
        institution: close_institution,
        rate: ~M[0],
        end: datetime(yesterday, {12, 0, 0}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    today_ride =
      Repo.insert!(%Ride{
        start: datetime(today, {11, 0, 0}),
        institution: far_institution,
        end: datetime(today, {12, 0, 0}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    tomorrow_ride =
      Repo.insert!(%Ride{
        start: datetime(tomorrow, {17, 0, 0}),
        institution: far_institution,
        end: datetime(tomorrow, {18, 0, 0}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    already_set_gas_price_ride =
      Repo.insert!(%Ride{
        start: datetime(Date.add(today, 4), {11, 0, 0}),
        institution: far_institution,
        gas_price: ancient_price,
        end: datetime(Date.add(today, 4), {12, 0, 0}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    already_set_rate_ride =
      Repo.insert!(%Ride{
        start: datetime(yesterday, {11, 1, 0}),
        institution: close_institution,
        rate: ~M[100],
        end: datetime(yesterday, {12, 1, 0}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    Mix.Tasks.StoreRates.run([])

    ancient = reload_ride(ancient_ride)
    old = reload_ride(old_ride)
    yesterday = reload_ride(yesterday_ride)
    zero_rate_ride = reload_ride(zero_set_rate_ride)
    already_set_rate = reload_ride(already_set_rate_ride)
    today = reload_ride(today_ride)
    tomorrow = reload_ride(tomorrow_ride)
    already_set_gas_price = reload_ride(already_set_gas_price_ride)

    assert ancient.gas_price.id == ancient_price.id

    assert old.gas_price.id == yesterday_price.id
    assert old.rate == ~M[23]

    assert yesterday.gas_price.id == yesterday_price.id
    assert yesterday.rate == ~M[23]

    assert zero_rate_ride.gas_price.id == yesterday_price.id
    assert zero_rate_ride.rate == ~M[23]

    assert today.gas_price.id == today_price.id
    assert today.rate == ~M[20]

    refute tomorrow.gas_price
    refute tomorrow.rate

    assert already_set_gas_price.gas_price.id == ancient_price.id
    refute already_set_rate.gas_price

    ancient_version = hd(Repo.all(PaperTrail.Version))

    assert ancient_version.event == "update"
    assert ancient_version.origin == "StoreRates"
    assert ancient_version.item_id == ancient.id

    assert_delivered_email(
      PrisonRideshare.Email.store_rates_gap_warning_report(ancient, ancient_price)
    )

    assert_delivered_email(
      PrisonRideshare.Email.store_rates_gap_warning_report(old, yesterday_price)
    )
  end

  test "does not assign rates for future rides" do
    today = Date.utc_today()
    future_date = Date.add(today, 2)

    _future_price =
      Repo.insert!(%GasPrice{
        price: 120,
        inserted_at: datetime(future_date, {8, 0, 0})
      })

    institution =
      Repo.insert!(%Institution{
        name: "Close",
        far: false
      })

    ride =
      Repo.insert!(%Ride{
        start: datetime(future_date, {10, 0, 0}),
        institution: institution,
        end: datetime(future_date, {11, 0, 0}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    Mix.Tasks.StoreRates.run([])

    updated_ride = reload_ride(ride)

    refute updated_ride.gas_price
    refute updated_ride.rate

    assert_no_emails_delivered()
  end
end
