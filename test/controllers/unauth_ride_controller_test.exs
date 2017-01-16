defmodule PrisonRideshare.UnauthRideControllerTest do
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.{Institution, Ride}
  alias PrisonRideshare.Repo

  setup do
    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "lists all publicly-available ride data on index", %{conn: conn} do
    institution = Repo.insert! %Institution{name: "Stony Mountain"}
    ride = Repo.insert! %Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 15}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 15}, {20, 0, 0}}),
      institution: institution
    }

    conn = get conn, ride_path(conn, :index)
    assert json_response(conn, 200)["data"] == [%{
      "id" => ride.id,
      "type" => "ride",
      "attributes" => %{
        "start" => "2017-01-15T18:00:00",
        "end" => "2017-01-15T20:00:00"
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
end
