defmodule PrisonRideshare.RideControllerTest do
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.Ride
  alias PrisonRideshare.Repo

  @valid_attrs %{address: "some content", car_expenses: 42, contact: "some content", date: %{day: 17, month: 4, year: 2010}, distance: "120.5", end: %{hour: 14, min: 0, sec: 0}, food_expenses: 42, name: "some content", passengers: 42, rate: 42, report_notes: "some content", request_notes: "some content", start: %{hour: 14, min: 0, sec: 0}}
  @invalid_attrs %{}

  setup do
    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  defp relationships do
    combined_with_ride = Repo.insert!(%PrisonRideshare.Ride{})
    institution = Repo.insert!(%PrisonRideshare.Institution{})
    driver = Repo.insert!(%PrisonRideshare.Person{})
    car_owner = Repo.insert!(%PrisonRideshare.Person{})

    %{
      "combined_with_ride" => %{
        "data" => %{
          "type" => "combined_with_ride",
          "id" => combined_with_ride.id
        }
      },
      "institution" => %{
        "data" => %{
          "type" => "institution",
          "id" => institution.id
        }
      },
      "driver" => %{
        "data" => %{
          "type" => "driver",
          "id" => driver.id
        }
      },
      "car_owner" => %{
        "data" => %{
          "type" => "car_owner",
          "id" => car_owner.id
        }
      },
    }
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, ride_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    ride = Repo.insert! %Ride{rate: 35}
    conn = get conn, ride_path(conn, :show, ride)
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{ride.id}"
    assert data["type"] == "ride"
    assert data["attributes"]["date"] == ride.date
    assert data["attributes"]["start"] == ride.start
    assert data["attributes"]["end"] == ride.end
    assert data["attributes"]["name"] == ride.name
    assert data["attributes"]["address"] == ride.address
    assert data["attributes"]["contact"] == ride.contact
    assert data["attributes"]["passengers"] == ride.passengers
    assert data["attributes"]["request_notes"] == ride.request_notes
    assert data["attributes"]["distance"] == ride.distance
    assert data["attributes"]["rate"] == ride.rate
    assert data["attributes"]["food_expenses"] == ride.food_expenses
    assert data["attributes"]["car_expenses"] == ride.car_expenses
    assert data["attributes"]["report_notes"] == ride.report_notes
    assert data["attributes"]["combined_with_ride_id"] == ride.combined_with_ride_id
    assert data["attributes"]["institution_id"] == ride.institution_id
    assert data["attributes"]["driver_id"] == ride.driver_id
    assert data["attributes"]["car_owner_id"] == ride.car_owner_id
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, ride_path(conn, :show, "00000000-0000-0000-0000-000000000000")
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, ride_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "ride",
        "attributes" => @valid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Ride, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, ride_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "ride",
        "attributes" => @invalid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    ride = Repo.insert! %Ride{}
    conn = put conn, ride_path(conn, :update, ride), %{
      "meta" => %{},
      "data" => %{
        "type" => "ride",
        "id" => ride.id,
        "attributes" => @valid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Ride, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    ride = Repo.insert! %Ride{}
    conn = put conn, ride_path(conn, :update, ride), %{
      "meta" => %{},
      "data" => %{
        "type" => "ride",
        "id" => ride.id,
        "attributes" => @invalid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    ride = Repo.insert! %Ride{}
    conn = delete conn, ride_path(conn, :delete, ride)
    assert response(conn, 204)
    refute Repo.get(Ride, ride.id)
  end

end
