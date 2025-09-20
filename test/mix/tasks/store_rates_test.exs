defmodule Mix.Tasks.StoreRatesTest do
  use ExUnit.Case
  use PrisonRideshareWeb.ConnCase
  use Bamboo.Test

  alias PrisonRideshare.Repo

  alias PrisonRideshareWeb.{GasPrice, Institution, Ride}

  import Money.Sigils
  import Ecto.Query

  test "running the rate calculator" do
    yesterday_price =
      Repo.insert!(%GasPrice{
        price: 90,
        inserted_at: NaiveDateTime.from_erl!({{2018, 6, 23}, {8, 0, 0}})
      })

    today_price =
      Repo.insert!(%GasPrice{
        price: 100,
        inserted_at: NaiveDateTime.from_erl!({{2018, 6, 24}, {16, 37, 0}})
      })

    ancient_price =
      Repo.insert!(%GasPrice{
        price: 5,
        inserted_at: NaiveDateTime.from_erl!({{2017, 1, 1}, {0, 0, 0}})
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

    _ancient_ride =
      Repo.insert!(%Ride{
        start: NaiveDateTime.from_erl!({{2017, 2, 2}, {11, 0, 0}}),
        institution: close_institution,
        end: NaiveDateTime.from_erl!({{2017, 2, 2}, {12, 0, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _old_ride =
      Repo.insert!(%Ride{
        start: NaiveDateTime.from_erl!({{2018, 5, 23}, {11, 0, 0}}),
        institution: close_institution,
        end: NaiveDateTime.from_erl!({{2018, 5, 23}, {12, 0, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _yesterday_ride =
      Repo.insert!(%Ride{
        start: NaiveDateTime.from_erl!({{2018, 6, 23}, {11, 0, 0}}),
        institution: close_institution,
        end: NaiveDateTime.from_erl!({{2018, 6, 23}, {12, 0, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _zero_set_rate_ride =
      Repo.insert!(%Ride{
        start: NaiveDateTime.from_erl!({{2018, 6, 23}, {11, 0, 1}}),
        institution: close_institution,
        rate: ~M[0],
        end: NaiveDateTime.from_erl!({{2018, 6, 23}, {12, 0, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _today_ride =
      Repo.insert!(%Ride{
        start: NaiveDateTime.from_erl!({{2018, 6, 24}, {11, 0, 0}}),
        institution: far_institution,
        end: NaiveDateTime.from_erl!({{2018, 6, 24}, {12, 0, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _tomorrow_ride =
      Repo.insert!(%Ride{
        start: NaiveDateTime.from_erl!({{2018, 6, 25}, {17, 0, 0}}),
        institution: far_institution,
        end: NaiveDateTime.from_erl!({{2018, 6, 25}, {18, 0, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _already_set_gas_price_ride =
      Repo.insert!(%Ride{
        start: NaiveDateTime.from_erl!({{2018, 6, 28}, {11, 0, 0}}),
        institution: far_institution,
        gas_price: ancient_price,
        end: NaiveDateTime.from_erl!({{2018, 6, 28}, {12, 0, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _already_set_rate_ride =
      Repo.insert!(%Ride{
        start: NaiveDateTime.from_erl!({{2018, 6, 23}, {11, 1, 0}}),
        institution: close_institution,
        rate: ~M[100],
        end: NaiveDateTime.from_erl!({{2018, 6, 23}, {12, 1, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    Mix.Tasks.StoreRates.run([])

    [
      ancient,
      old,
      yesterday,
      zero_rate_ride,
      already_set_rate,
      today,
      tomorrow,
      already_set_gas_price
    ] =
      Ride
      |> order_by(:start)
      |> preload(:gas_price)
      |> Repo.all()

    assert ancient.gas_price.id == ancient_price.id

    assert old.gas_price.id == yesterday_price.id
    assert old.rate == ~M[23]

    assert yesterday.gas_price.id == yesterday_price.id
    assert yesterday.rate == ~M[23]

    assert zero_rate_ride.gas_price.id == yesterday_price.id
    assert yesterday.rate == ~M[23]

    assert today.gas_price.id == today_price.id
    assert today.rate == ~M[20]

    assert tomorrow.gas_price.id == today_price.id
    assert tomorrow.rate == ~M[20]

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
end
