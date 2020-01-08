defmodule PrisonRideshare.RideCalendarTest do
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshareWeb.{Institution, Person, Ride}
  alias PrisonRideshare.Repo

  import Money.Sigils

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "text/calendar")
      |> put_req_header("content-type", "text/calendar")

    {:ok, conn: conn}
  end

  test "lists unfilled and not-cancelled ride events", %{conn: conn} do
    institution = Repo.insert!(%Institution{name: "Stony Mountain"})
    driver = Repo.insert!(%Person{name: "Chelsea Manning"})

    Repo.insert!(%Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 14}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 14}, {20, 0, 0}}),
      institution: institution,
      name: "Tom",
      passengers: 1,
      address: "421 Osborne",
      contact: "2877433"
    })

    ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2017, 1, 15}, {18, 0, 0}}),
        end: Ecto.DateTime.from_erl({{2017, 1, 15}, {20, 0, 0}}),
        institution: institution,
        name: "Tom",
        passengers: 2,
        address: "421 Osborne",
        contact: "2877433"
      })

    Repo.insert!(%Ride{
      institution: institution,
      combined_with: ride,
      name: "Tina",
      passengers: 1,
      address: "414 Osborne",
      contact: "287878"
    })

    Repo.insert!(%Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 16}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 16}, {20, 0, 0}}),
      institution: institution,
      name: "Tom",
      passengers: 1,
      address: "421 Osborne",
      contact: "2877433"
    })

    # This ride should not be visible since it was cancelled.
    Repo.insert!(%Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 16}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 16}, {20, 0, 0}}),
      enabled: false,
      institution: institution
    })

    # This ride should not be visible since it has a driver.
    Repo.insert!(%Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 17}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 17}, {20, 0, 0}}),
      institution: institution,
      driver: driver,
      address: "421 Osborne"
    })

    # This ride should not be visible since it has a distance.
    Repo.insert!(%Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 17}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 17}, {20, 0, 0}}),
      institution: institution,
      address: "421 Osborne",
      distance: 44
    })

    # This ride should not be visible since it has car expenses.
    Repo.insert!(%Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 17}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 17}, {20, 0, 0}}),
      institution: institution,
      address: "421 Osborne",
      car_expenses: ~M[11]
    })

    conn = get(conn, ride_path(conn, :calendar))
    assert response_content_type(conn, :calendar)

    assert response(conn, 200) == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           BEGIN:VEVENT
           DESCRIPTION:Please email barnone.coordinator@gmail.com to get assigned to this ride.
           DTEND;TZID=Etc/UTC:20170114T200000
           DTSTART;TZID=Etc/UTC:20170114T180000
           SUMMARY:Stony Mountain: 1 request
           END:VEVENT
           BEGIN:VEVENT
           DESCRIPTION:Please email barnone.coordinator@gmail.com to get assigned to this ride.
           DTEND;TZID=Etc/UTC:20170115T200000
           DTSTART;TZID=Etc/UTC:20170115T180000
           SUMMARY:Stony Mountain: 2 requests, 3 passengers
           END:VEVENT
           BEGIN:VEVENT
           DESCRIPTION:Please email barnone.coordinator@gmail.com to get assigned to this ride.
           DTEND;TZID=Etc/UTC:20170116T200000
           DTSTART;TZID=Etc/UTC:20170116T180000
           SUMMARY:Stony Mountain: 1 request
           END:VEVENT
           END:VCALENDAR
           """
  end
end
