defmodule PrisonRideshareWeb.RideControllerTest do
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshareWeb.{Institution, Person, Reimbursement, Ride}
  alias PrisonRideshare.Repo

  @valid_attrs %{address: "some content", car_expenses: 42, contact: "some content", distance: 120, end: %{day: 17, month: 4, year: 2010, hour: 14, min: 0, sec: 0}, food_expenses: 42, name: "some content", passengers: 42, rate: 42, report_notes: "some content", request_notes: "some content", start: %{day: 17, month: 4, year: 2010, hour: 14, min: 0, sec: 0}}
  @invalid_attrs %{}

  setup do
    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> auth_as_admin

    {:ok, conn: conn}
  end

  defp relationships do
    combined_with_ride = Repo.insert!(%Ride{request_notes: "Combined"})
    institution = Repo.insert!(%Institution{})
    driver = Repo.insert!(%Person{name: "Driver Name"})
    car_owner = Repo.insert!(%Person{name: "Car Owner"})
    reimbursement = Repo.insert!(%Reimbursement{food_expenses: 2010, car_expenses: 2017})

    %{
      "combined-with" => %{
        "data" => %{
          "type" => "ride",
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
          "type" => "person",
          "id" => driver.id
        }
      },
      "car-owner" => %{
        "data" => %{
          "type" => "person",
          "id" => car_owner.id
        }
      },
      "reimbursements" => %{
        "data" => [
          %{
            "type" => "reimbursement",
            "id" => reimbursement.id
          }
        ]
      }
    }
  end

  test "lists all entries on index", %{conn: conn} do
    institution = Repo.insert! %Institution{name: "Stony Mountain"}
    driver = Repo.insert! %Person{name: "Driver Name"}
    car_owner = Repo.insert! %Person{name: "Car Owner"}
    reimbursement = Repo.insert! %Reimbursement{}
    ride = Repo.insert! %Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 15}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 15}, {20, 0, 0}}),
      institution: institution,
      rate: 35,
      passengers: 2,
      name: "Janis",
      contact: "jorts@jants.ca",
      address: "114 Spence St.",
      cancellation_reason: "",
      car_expenses: 44,
      distance: 55,
      enabled: true,
      food_expenses: 66,
      request_notes: "request!",
      report_notes: "report!",
      donation: true,
      driver: driver,
      car_owner: car_owner,
      reimbursements: [reimbursement]
    }

    conn = get conn, ride_path(conn, :index)
    assert json_response(conn, 200)["data"] == [%{
      "id" => ride.id,
      "type" => "ride",
      "attributes" => %{
        "start" => "2017-01-15T18:00:00",
        "end" => "2017-01-15T20:00:00",
        "rate" => ride.rate,
        "passengers" => ride.passengers,
        "name" => ride.name,
        "contact" => ride.contact,
        "address" => ride.address,
        "cancellation-reason" => ride.cancellation_reason,
        "car-expenses" => ride.car_expenses,
        "distance" => ride.distance,
        "enabled" => ride.enabled,
        "food-expenses" => ride.food_expenses,
        "request-notes" => ride.request_notes,
        "report-notes" => ride.report_notes,
        "donation" => true,
        "initials" => "DN",
        "inserted-at" => DateTime.to_iso8601(ride.inserted_at),
        "updated-at" => DateTime.to_iso8601(ride.updated_at)
      },
      "relationships" => %{
        "institution" => %{
          "data" => %{
            "type" => "institution",
            "id" => institution.id
          }
        },
        "driver" => %{
          "data" => %{
            "type" => "person",
            "id" => driver.id
          }
        },
        "car-owner" => %{
          "data" => %{
            "type" => "person",
            "id" => car_owner.id
          }
        },
        "combined-with" => %{
          "data" => nil
        },
        "children" => %{
          "data" => []
        },
        "reimbursements" => %{
          "data" => [%{
            "type" => "reimbursement",
            "id" => reimbursement.id
          }]
        }
      }
    }]
  end

  test "returns rides that match the visitor search", %{conn: conn} do
    francine_ride = Repo.insert! %Ride{name: "Francine"}
    Repo.insert! %Ride{name: "Pascal"}
    frank_ride = Repo.insert! %Ride{name: "frank"}
    Repo.insert! %Ride{name: "Safran"}

    conn = get conn, ride_path(conn, :index, "filter[name]": "fran")

    [ride1, ride2] = json_response(conn, 200)["data"]

    assert ride1["id"] == francine_ride.id
    assert ride2["id"] == frank_ride.id
  end

  test "shows chosen resource", %{conn: conn} do
    ride = Repo.insert! %Ride{rate: 35}
    conn = get conn, ride_path(conn, :show, ride)
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{ride.id}"
    # FIXME type should be plural in all responses
    assert data["type"] == "ride"
    assert data["attributes"]["start"] == ride.start
    assert data["attributes"]["end"] == ride.end
    assert data["attributes"]["name"] == ride.name
    assert data["attributes"]["address"] == ride.address
    assert data["attributes"]["contact"] == ride.contact
    assert data["attributes"]["passengers"] == ride.passengers
    assert data["attributes"]["request_notes"] == ride.request_notes
    assert data["attributes"]["distance"] == ride.distance
    assert data["attributes"]["rate"] == ride.rate
    assert data["attributes"]["food-expenses"] == ride.food_expenses
    assert data["attributes"]["car-expenses"] == ride.car_expenses
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
        "type" => "rides",
        "attributes" => @valid_attrs,
        "relationships" => relationships()
      }
    }

    ride = Repo.get_by(Ride, @valid_attrs)
    assert json_response(conn, 201)["data"]["id"] == ride.id
    assert json_response(conn, 201)["data"]["attributes"]["address"] == "some content"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, ride_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "rides",
        "attributes" => @invalid_attrs,
        "relationships" => relationships()
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    other_driver = Repo.insert!(%Person{name: "Other Driver"})

    ride = Repo.insert! %Ride{driver: other_driver}
    conn = put conn, ride_path(conn, :update, ride), %{
      "meta" => %{},
      "data" => %{
        "type" => "rides",
        "id" => ride.id,
        "attributes" => @valid_attrs,
        "relationships" => relationships()
      }
    }

    driver = Repo.get_by(Person, name: "Driver Name")
    car_owner = Repo.get_by(Person, name: "Car Owner")

    [_reimbursement] = Repo.all(Reimbursement)

    combined_with_ride = Repo.get_by(Ride, request_notes: "Combined")

    saved = Repo.get!(Ride, ride.id)

    assert saved

    assert saved.driver_id == driver.id
    assert saved.car_owner_id == car_owner.id
    assert saved.combined_with_ride_id == combined_with_ride.id

    data = json_response(conn, 200)["data"]

    assert data["relationships"] == %{
      "institution" => %{
        "data" => %{
          "type" => "institution",
          "id" => saved.institution_id
        }
      },
      "driver" => %{
        "data" => %{
          "type" => "person",
          "id" => driver.id
        }
      },
      "car-owner" => %{
        "data" => %{
          "type" => "person",
          "id" => car_owner.id
        }
      },
      "combined-with" => %{
        "data" => %{
          "type" => "ride",
          "id" => combined_with_ride.id
        }
      },
      "children" => %{
        "data" => []
      },
      "reimbursements" => %{
        "data" => [
          # FIXME why isn’t this saved?
          # %{
          #   "type" => "reimbursement",
          #   "id" => reimbursement.id
          # }
        ]
      }
    }

  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    ride = Repo.insert! %Ride{}
    conn = put conn, ride_path(conn, :update, ride), %{
      "meta" => %{},
      "data" => %{
        "type" => "rides",
        "id" => ride.id,
        "attributes" => @invalid_attrs,
        "relationships" => relationships()
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
