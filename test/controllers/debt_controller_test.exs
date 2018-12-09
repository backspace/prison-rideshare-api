import Money.Sigils

defmodule PrisonRideshareWeb.DebtControllerTest do
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshareWeb.{Person, Reimbursement, Ride}
  alias PrisonRideshare.Repo

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> auth_as_admin

    {:ok, conn: conn}
  end

  test "lists name-sorted people with outstanding debts and ignores settled debts", %{conn: conn} do
    sara = Repo.insert!(%Person{name: "Sara Ahmed"})
    cnuth = Repo.insert!(%Person{name: "Cnuth"})
    chelsea = Repo.insert!(%Person{name: "Chelsea Manning"})

    unreimbursed_ride =
      Repo.insert!(%Ride{
        driver: cnuth,
        car_owner: cnuth,
        food_expenses: 100,
        car_expenses: 1000
      })

    cnuth_ride_sara_car =
      Repo.insert!(%Ride{
        driver: cnuth,
        car_owner: sara,
        food_expenses: 50,
        car_expenses: 44203
      })

    reimbursed_ride =
      Repo.insert!(%Ride{
        driver: sara,
        car_owner: sara,
        food_expenses: 2006,
        car_expenses: 2010
      })

    other_reimbursed_ride =
      Repo.insert!(%Ride{
        driver: chelsea,
        car_owner: chelsea,
        food_expenses: 2017,
        car_expenses: 2017
      })

    Repo.insert!(%Reimbursement{
      person: sara,
      ride: cnuth_ride_sara_car,
      car_expenses: 42284
    })

    Repo.insert!(%Reimbursement{
      person: sara,
      ride: reimbursed_ride,
      car_expenses: 2010
    })

    Repo.insert!(%Reimbursement{
      person: sara,
      ride: reimbursed_ride,
      food_expenses: 2006
    })

    Repo.insert!(%Reimbursement{
      person: chelsea,
      ride: other_reimbursed_ride,
      car_expenses: 2017
    })

    Repo.insert!(%Reimbursement{
      person: chelsea,
      ride: other_reimbursed_ride,
      food_expenses: 2017
    })

    conn = get(conn, debt_path(conn, :index))

    assert json_response(conn, 200)["data"] == [
             %{
               "id" => cnuth.id,
               "type" => "debt",
               "attributes" => %{
                 "food-expenses" => 150,
                 "car-expenses" => 1000
               },
               "relationships" => %{
                 "person" => person_relationship_json(cnuth),
                 "rides" => %{
                   "data" => [
                     ride_relationship_json(unreimbursed_ride),
                     ride_relationship_json(cnuth_ride_sara_car)
                   ]
                 }
               }
             },
             %{
               "id" => sara.id,
               "type" => "debt",
               "attributes" => %{
                 "food-expenses" => 0,
                 "car-expenses" => 1919
               },
               "relationships" => %{
                 "person" => person_relationship_json(sara),
                 "rides" => %{
                   "data" => [
                     ride_relationship_json(cnuth_ride_sara_car)
                   ]
                 }
               }
             }
           ]
  end

  test "creates reimbursements for debts", %{conn: conn} do
    cnuth = Repo.insert!(%Person{name: "Cnuth"})
    other = Repo.insert!(%Person{})

    ride =
      Repo.insert!(%Ride{
        driver: cnuth,
        car_owner: cnuth,
        food_expenses: 100,
        car_expenses: 1000
      })

    donation_ride =
      Repo.insert!(%Ride{
        driver: cnuth,
        car_owner: cnuth,
        food_expenses: 0,
        car_expenses: 999,
        donation: true
      })

    food_ride =
      Repo.insert!(%Ride{
        driver: cnuth,
        car_owner: cnuth,
        food_expenses: 200,
        car_expenses: 0
      })

    Repo.insert!(%Ride{
      driver: cnuth,
      car_owner: other,
      food_expenses: 0,
      car_expenses: 100
    })

    Repo.insert!(%Reimbursement{
      person: cnuth,
      food_expenses: 5,
      ride: ride
    })

    conn = delete(conn, debt_path(conn, :delete, cnuth))

    [
      _existingreimbursement,
      donation_reimbursement,
      food_reimbursement_one,
      car_reimbursement,
      food_reimbursement_two
    ] =
      Repo.all(Reimbursement)
      |> Repo.preload([:ride, :person])

    assert donation_reimbursement.ride_id == donation_ride.id
    assert donation_reimbursement.car_expenses == ~M[999]
    assert donation_reimbursement.donation

    assert food_reimbursement_one.ride_id == ride.id
    assert food_reimbursement_one.person == cnuth
    assert food_reimbursement_one.food_expenses == ~M[95]
    assert food_reimbursement_one.car_expenses == ~M[0]
    refute food_reimbursement_one.donation

    assert car_reimbursement.ride_id == ride.id
    assert car_reimbursement.person == cnuth
    assert car_reimbursement.food_expenses == ~M[0]
    assert car_reimbursement.car_expenses == ~M[1000]
    refute car_reimbursement.donation

    assert food_reimbursement_two.ride_id == food_ride.id
    assert food_reimbursement_two.person == cnuth
    assert food_reimbursement_two.food_expenses == ~M[200]
    assert food_reimbursement_two.car_expenses == ~M[0]

    assert response(conn, 204)
  end

  defp person_relationship_json(person) do
    %{
      "data" => %{
        "type" => "people",
        "id" => person.id
      }
    }
  end

  defp ride_relationship_json(ride) do
    %{
      "type" => "ride",
      "id" => ride.id
    }
  end
end
