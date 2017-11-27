defmodule PrisonRideshare.RideCalendarTest do
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshareWeb.{Institution, Person, Ride}
  alias PrisonRideshare.Repo

  test "lists unfilled and not-cancelled ride events", %{conn: conn} do
    institution = Repo.insert! %Institution{name: "Stony Mountain"}
    driver = Repo.insert! %Person{name: "Chelsea Manning"}

    Repo.insert! %Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 14}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 14}, {20, 0, 0}}),
      institution: institution,
      name: "Tom",
      passengers: 1,
      address: "421 Osborne",
      contact: "2877433"
    }

    ride = Repo.insert! %Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 15}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 15}, {20, 0, 0}}),
      institution: institution,
      name: "Tom",
      passengers: 2,
      address: "421 Osborne",
      contact: "2877433"
    }

    Repo.insert! %Ride{
      combined_with: ride,
      name: "Tina",
      passengers: 1,
      address: "414 Osborne",
      contact: "287878"
    }

    # This ride should not be visible since it was cancelled.
    Repo.insert! %Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 16}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 16}, {20, 0, 0}}),
      enabled: false,
      institution: institution
    }

    # This ride should not be visible since it has a driver.
    Repo.insert! %Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 17}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 17}, {20, 0, 0}}),
      institution: institution,
      driver: driver,
      address: "421 Osborne"
    }

    conn = get conn, ride_path(conn, :calendar)
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
    END:VCALENDAR
    """
  end
end
