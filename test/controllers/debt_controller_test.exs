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
    Repo.insert! %Person{name: "Chelsea Manning"}

    Repo.insert! %Ride{
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

    Repo.insert! %Reimbursement{
      person: sara,
      ride: curtis_ride_sara_car,
      car_expenses: 42284,
      food_expenses: 0
    }

    Repo.insert! %Reimbursement{
      person: sara,
      ride: reimbursed_ride,
      car_expenses: 2010,
      food_expenses: 0
    }

    Repo.insert! %Reimbursement{
      person: sara,
      ride: reimbursed_ride,
      car_expenses: 0,
      food_expenses: 2006
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
        "person" => person_relationship_json(curtis)
      }
    }, %{
      "id" => sara.id,
      "type" => "debt",
      "attributes" => %{
        "food-expenses" => 0,
        "car-expenses" => 1919
      },
      "relationships" => %{
        "person" => person_relationship_json(sara)
      }
    }]
  end

  defp person_relationship_json(person) do
    %{
      "data" => %{
        "type" => "person",
        "id" => person.id
      }
    }
  end
end
