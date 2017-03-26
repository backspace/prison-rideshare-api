import Money.Sigils

defmodule PrisonRideshare.DebtControllerTest do
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.{Person, Reimbursement, Ride}
  alias PrisonRideshare.Repo

  setup do
    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> auth_as_admin

    {:ok, conn: conn}
  end

  test "lists people with outstanding debts and ignores settled debts", %{conn: conn} do
    curtis = Repo.insert! %Person{name: "Curtis"}
    sara = Repo.insert! %Person{name: "Sara Ahmed"}
    chelsea = Repo.insert! %Person{name: "Chelsea Manning"}

    unreimbursed_ride = Repo.insert! %Ride{
      driver: curtis,
      car_owner: curtis,
      food_expenses: 100,
      car_expenses: 1000
    }

    curtis_ride_sara_car = Repo.insert! %Ride{
      driver: curtis,
      car_owner: sara,
      food_expenses: 50,
      car_expenses: 44203
    }

    reimbursed_ride = Repo.insert! %Ride{
      driver: sara,
      car_owner: sara,
      food_expenses: 2006,
      car_expenses: 2010
    }

    other_reimbursed_ride = Repo.insert! %Ride{
      driver: chelsea,
      car_owner: chelsea,
      food_expenses: 2017,
      car_expenses: 2017
    }

    Repo.insert! %Reimbursement{
      person: sara,
      ride: curtis_ride_sara_car,
      car_expenses: 42284
    }

    Repo.insert! %Reimbursement{
      person: sara,
      ride: reimbursed_ride,
      car_expenses: 2010
    }

    Repo.insert! %Reimbursement{
      person: sara,
      ride: reimbursed_ride,
      food_expenses: 2006
    }

    Repo.insert! %Reimbursement{
      person: chelsea,
      ride: other_reimbursed_ride,
      car_expenses: 2017
    }

    Repo.insert! %Reimbursement{
      person: chelsea,
      ride: other_reimbursed_ride,
      food_expenses: 2017
    }

    conn = get conn, debt_path(conn, :index)
    assert json_response(conn, 200)["data"] == [%{
      "id" => curtis.id,
      "type" => "debt",
      "attributes" => %{
        "food-expenses" => 150,
        "car-expenses" => 1000
      },
      "relationships" => %{
        "person" => person_relationship_json(curtis),
        "rides" => %{
          "data" => [
            ride_relationship_json(unreimbursed_ride),
            ride_relationship_json(curtis_ride_sara_car)
          ]
        }
      }
    }, %{
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
            ride_relationship_json(curtis_ride_sara_car)
          ]
        }
      }
    }]
  end

  test "creates reimbursements for debts", %{conn: conn} do
    curtis = Repo.insert! %Person{name: "Curtis"}
    other = Repo.insert! %Person{}

    ride = Repo.insert! %Ride{
      driver: curtis,
      car_owner: curtis,
      food_expenses: 100,
      car_expenses: 1000
    }

    food_ride = Repo.insert! %Ride{
      driver: curtis,
      car_owner: curtis,
      food_expenses: 200,
      car_expenses: 0
    }

    Repo.insert! %Ride{
      driver: curtis,
      car_owner: other,
      food_expenses: 0,
      car_expenses: 100
    }

    Repo.insert! %Reimbursement{
      person: curtis,
      food_expenses: 5,
      ride: ride
    }

    conn = delete conn, debt_path(conn, :delete, curtis)

    [_existingreimbursement, food_reimbursement_one, car_reimbursement, food_reimbursement_two] = Repo.all(Reimbursement)
    |> Repo.preload([:ride, :person])

    assert food_reimbursement_one.ride_id == ride.id
    assert food_reimbursement_one.person == curtis
    assert food_reimbursement_one.food_expenses == ~M[95]
    assert food_reimbursement_one.car_expenses == ~M[0]

    assert car_reimbursement.ride_id == ride.id
    assert car_reimbursement.person == curtis
    assert car_reimbursement.food_expenses == ~M[0]
    assert car_reimbursement.car_expenses == ~M[1000]

    assert food_reimbursement_two.ride_id == food_ride.id
    assert food_reimbursement_two.person == curtis
    assert food_reimbursement_two.food_expenses == ~M[200]
    assert food_reimbursement_two.car_expenses == ~M[0]

    assert response(conn, 204)
  end

  defp person_relationship_json(person) do
    %{
      "data" => %{
        "type" => "person",
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
