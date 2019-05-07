defmodule PrisonRideshare.UnauthRideControllerTest do
  use PrisonRideshareWeb.ConnCase
  use Bamboo.Test

  alias PrisonRideshareWeb.{Institution, Person, Ride}
  alias PrisonRideshare.Repo

  import Money.Sigils

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "lists all publicly-available driver-assigned enabled-and-not-complete-and-not-combined ride data on index",
       %{conn: conn} do
    institution = Repo.insert!(%Institution{name: "Stony Mountain"})
    driver = Repo.insert!(%Person{name: "Chelsea Manning"})

    ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2017, 1, 15}, {18, 0, 0}}),
        end: Ecto.DateTime.from_erl({{2017, 1, 15}, {20, 0, 0}}),
        institution: institution,
        rate: ~M[33],
        driver: driver
      })

    donatable_ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2017, 2, 15}, {18, 0, 0}}),
        end: Ecto.DateTime.from_erl({{2017, 2, 15}, {20, 0, 0}}),
        institution: institution,
        driver: driver,
        car_owner: driver,
        overridable: true
      })

    Repo.insert!(%Ride{
      enabled: false
    })

    Repo.insert!(%Ride{
      distance: 77
    })

    Repo.insert!(%Ride{
      driver: driver,
      complete: true
    })

    Repo.insert!(%Ride{
      combined_with: ride
    })

    Repo.insert!(%Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 15}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 15}, {20, 0, 0}}),
      institution: institution,
      car_owner: driver
    })

    conn = get(conn, ride_path(conn, :index))

    assert json_response(conn, 200)["data"] == [
             %{
               "id" => donatable_ride.id,
               "type" => "ride",
               "attributes" => %{
                 "start" => "2017-02-15T18:00:00Z",
                 "end" => "2017-02-15T20:00:00Z",
                 "initials" => "CM",
                 "donatable" => true,
                 "overridable" => true,
                 "rate" => nil
               },
               "relationships" => %{
                 "institution" => %{
                   "data" => %{
                     "type" => "institution",
                     "id" => institution.id
                   }
                 }
               }
             },
             %{
               "id" => ride.id,
               "type" => "ride",
               "attributes" => %{
                 "start" => "2017-01-15T18:00:00Z",
                 "end" => "2017-01-15T20:00:00Z",
                 "initials" => "CM",
                 "donatable" => false,
                 "overridable" => false,
                 "rate" => 33
               },
               "relationships" => %{
                 "institution" => %{
                   "data" => %{
                     "type" => "institution",
                     "id" => institution.id
                   }
                 }
               }
             }
           ]
  end

  test "updates and renders chosen resource when data is valid, ignoring auth-requiring attributes, calculating car expenses, and sending an email",
       %{conn: conn} do
    ride_institution = Repo.insert!(%Institution{name: "Stony Mountain"})
    driver = Repo.insert!(%Person{name: "Chelsea Manning"})

    ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2017, 1, 15}, {18, 0, 0}}),
        end: Ecto.DateTime.from_erl({{2017, 1, 15}, {20, 0, 0}}),
        institution: ride_institution,
        rate: ~M[44],
        driver: driver,
        request_notes: "The original request notes"
      })

    attempted_institution = Repo.insert!(%Institution{name: "Toys R Us"})

    conn =
      put(conn, ride_path(conn, :update, ride), %{
        "meta" => %{},
        "data" => %{
          "type" => "rides",
          "id" => ride.id,
          "attributes" => %{
            "distance" => 77,
            "food_expenses" => 1000,
            "report_notes" => "Some report notes",
            "request_notes" => "Trying it!",
            "donation" => true,
            "overridable" => true
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
      })

    assert json_response(conn, 200)["data"] == %{
             "id" => ride.id,
             "type" => "ride",
             "attributes" => %{
               "start" => "2017-01-15T18:00:00Z",
               "end" => "2017-01-15T20:00:00Z",
               "initials" => "CM",
               # FIXME this shouldn’t have been updated as a donation then
               "donatable" => false,
               "overridable" => false,
               "rate" => 44
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

    ride =
      Repo.get!(Ride, ride.id)
      |> Repo.preload([:institution, :driver])

    assert ride.institution_id == ride_institution.id
    assert ride.distance == 77
    assert ride.food_expenses == ~M[1000]
    assert ride.car_expenses == ~M[3388]
    assert ride.report_notes == "Some report notes"
    assert ride.request_notes == "The original request notes"
    assert ride.donation
    assert ride.complete
    refute ride.overridable

    assert_delivered_email(PrisonRideshare.Email.report(ride))
  end

  test "updates car expenses when overridable",
       %{conn: conn} do
    ride_institution = Repo.insert!(%Institution{name: "Stony Mountain"})
    driver = Repo.insert!(%Person{name: "Chelsea Manning"})

    ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2017, 1, 15}, {18, 0, 0}}),
        end: Ecto.DateTime.from_erl({{2017, 1, 15}, {20, 0, 0}}),
        institution: ride_institution,
        rate: ~M[44],
        driver: driver,
        overridable: true
      })

    conn =
      put(conn, ride_path(conn, :update, ride), %{
        "meta" => %{},
        "data" => %{
          "type" => "rides",
          "id" => ride.id,
          "attributes" => %{
            "distance" => 77,
            "car_expenses" => 100
          }
        }
      })

    assert json_response(conn, 200)["data"] == %{
             "id" => ride.id,
             "type" => "ride",
             "attributes" => %{
               "start" => "2017-01-15T18:00:00Z",
               "end" => "2017-01-15T20:00:00Z",
               "initials" => "CM",
               "donatable" => false,
               "overridable" => true,
               "rate" => 44
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

    ride =
      Repo.get!(Ride, ride.id)
      |> Repo.preload([:institution, :driver])

    assert ride.distance == 77
    assert ride.car_expenses == ~M[100]
    assert ride.complete
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    ride = Repo.insert!(%Ride{})

    conn =
      put(conn, ride_path(conn, :update, ride), %{
        "meta" => %{},
        "data" => %{
          "type" => "rides",
          "id" => ride.id,
          "attributes" => %{},
          "relationships" => %{}
        }
      })

    assert json_response(conn, 422)["errors"] == [
             %{
               "detail" => "Distance can't be blank",
               "source" => %{"pointer" => "/data/attributes/distance"},
               "title" => "can't be blank"
             }
             # TODO 🤔 skipped because it has a default value…?
             # %{"detail" => "Food expenses can't be blank", "source" => %{"pointer" => "/data/attributes/food-expenses"}, "title" => "can't be blank"}
           ]

    assert_no_emails_delivered()
  end
end
