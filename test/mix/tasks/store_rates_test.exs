defmodule Mix.Tasks.StoreRatesTest do
  use ExUnit.Case
  use PrisonRideshareWeb.ConnCase

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

    other_price =
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

    _old_ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2018, 5, 23}, {11, 0, 0}}),
        institution: close_institution,
        end: Ecto.DateTime.from_erl({{2018, 5, 23}, {12, 0, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _yesterday_ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2018, 6, 23}, {11, 0, 0}}),
        institution: close_institution,
        end: Ecto.DateTime.from_erl({{2018, 6, 23}, {12, 0, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _zero_set_rate_ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2018, 6, 23}, {11, 0, 1}}),
        institution: close_institution,
        rate: ~M[0],
        end: Ecto.DateTime.from_erl({{2018, 6, 23}, {12, 0, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _today_ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2018, 6, 24}, {11, 0, 0}}),
        institution: far_institution,
        end: Ecto.DateTime.from_erl({{2018, 6, 24}, {12, 0, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _tomorrow_ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2018, 6, 25}, {17, 0, 0}}),
        institution: far_institution,
        end: Ecto.DateTime.from_erl({{2018, 6, 25}, {18, 0, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _already_set_gas_price_ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2018, 6, 28}, {11, 0, 0}}),
        gas_price: other_price,
        end: Ecto.DateTime.from_erl({{2018, 6, 28}, {12, 0, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _already_set_rate_ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2018, 6, 23}, {11, 1, 0}}),
        institution: close_institution,
        rate: ~M[100],
        end: Ecto.DateTime.from_erl({{2018, 6, 23}, {12, 1, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    _no_institution_ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2018, 6, 23}, {11, 2, 0}}),
        end: Ecto.DateTime.from_erl({{2018, 6, 23}, {12, 2, 0}}),
        address: "address",
        contact: "contact",
        name: "name"
      })

    Mix.Tasks.StoreRates.run([])

    [
      old,
      yesterday,
      zero_rate_ride,
      already_set_rate,
      no_institution_ride,
      today,
      tomorrow,
      already_set_gas_price
    ] =
      Ride
      |> order_by(:start)
      |> preload(:gas_price)
      |> Repo.all()

    refute old.gas_price

    assert yesterday.gas_price.id == yesterday_price.id
    assert yesterday.rate == ~M[23]

    assert zero_rate_ride.gas_price.id == yesterday_price.id
    assert yesterday.rate == ~M[23]

    assert today.gas_price.id == today_price.id
    assert today.rate == ~M[20]

    refute tomorrow.gas_price

    assert already_set_gas_price.gas_price.id == other_price.id
    refute already_set_rate.gas_price
    refute no_institution_ride.gas_price

    [yesterday_version, _zero_version, _today_version] = Repo.all(PaperTrail.Version)
    assert yesterday_version.event == "update"
    assert yesterday_version.origin == "StoreRates"
    assert yesterday_version.item_id == yesterday.id
  end
end
