defmodule PrisonRideshare.UnauthRideControllerTest do
  use PrisonRideshareWeb.ConnCase
  use Bamboo.Test

  alias PrisonRideshareWeb.{Institution, Person, Ride}
  alias PrisonRideshare.Repo

  import Money.Sigils

  setup do
    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "lists all publicly-available enabled-and-not-complete-and-not-combined ride data on index", %{conn: conn} do
    institution = Repo.insert! %Institution{name: "Stony Mountain"}
    driver = Repo.insert! %Person{name: "Chelsea Manning"}
    ride = Repo.insert! %Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 15}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 15}, {20, 0, 0}}),
      institution: institution,
      driver: driver
    }

    Repo.insert! %Ride{
      enabled: false
    }

    Repo.insert! %Ride{
      distance: 77
    }

    Repo.insert! %Ride{
      combined_with: ride
    }

    conn = get conn, ride_path(conn, :index)
    assert json_response(conn, 200)["data"] == [%{
      "id" => ride.id,
      "type" => "ride",
      "attributes" => %{
        "start" => "2017-01-15T18:00:00Z",
        "end" => "2017-01-15T20:00:00Z",
        "initials" => "CM"
      },
      "relationships" => %{
        "institution" => %{
          "data" => %{
            "type" => "institution",
            "id" => institution.id
          }
        }
      }
    }]
  end

  test "updates and renders chosen resource when data is valid, ignoring auth-requiring attributes, calculating car expenses, and sending an email", %{conn: conn} do
    ride_institution = Repo.insert! %Institution{name: "Stony Mountain", rate: 44}
    driver = Repo.insert! %Person{name: "Chelsea Manning"}

    ride = Repo.insert! %Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 15}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 15}, {20, 0, 0}}),
      institution: ride_institution,
      driver: driver,
      request_notes: "The original request notes"
    }

    attempted_institution = Repo.insert! %Institution{name: "Toys R Us"}

    conn = put conn, ride_path(conn, :update, ride), %{
      "meta" => %{},
      "data" => %{
        "type" => "rides",
        "id" => ride.id,
        "attributes" => %{
          "distance" => 77,
          "food_expenses" => 1000,
          "report_notes" => "Some report notes",
          "request_notes" => "Trying it!",
          "donation" => true
        },
        "relationships" => %{
          "institution" => %{
            "data" => %{
              "type" => "institution",
              "id" => attempted_institution.id
            }
          }
        }
      }
    }

    assert json_response(conn, 200)["data"] == %{
      "id" => ride.id,
      "type" => "ride",
      "attributes" => %{
        "start" => "2017-01-15T18:00:00Z",
        "end" => "2017-01-15T20:00:00Z",
        "initials" => "CM"
      },
      "relationships" => %{
        "institution" => %{
          "data" => %{
            "type" => "institution",
            "id" => ride_institution.id
          }
        }
      }
    }

    ride = Repo.get!(Ride, ride.id)
    |> Repo.preload([:institution, :driver])

    assert ride.institution_id == ride_institution.id
    assert ride.distance == 77
    assert ride.food_expenses == ~M[1000]
    assert ride.car_expenses == ~M[3388]
    assert ride.report_notes == "Some report notes"
    assert ride.request_notes == "The original request notes"
    assert ride.donation

    assert_delivered_email PrisonRideshare.Email.report(ride)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    ride = Repo.insert! %Ride{}

    conn = put conn, ride_path(conn, :update, ride), %{
      "meta" => %{},
      "data" => %{
        "type" => "rides",
        "id" => ride.id,
        "attributes" => %{},
        "relationships" => %{}
      }
    }

    assert json_response(conn, 422)["errors"] == [
      %{"detail" => "Distance can't be blank", "source" => %{"pointer" => "/data/attributes/distance"}, "title" => "can't be blank"},
      # TODO 🤔 skipped because it has a default value…?
      # %{"detail" => "Food expenses can't be blank", "source" => %{"pointer" => "/data/attributes/food-expenses"}, "title" => "can't be blank"}
    ]

    assert_no_emails_delivered()
  end
end
