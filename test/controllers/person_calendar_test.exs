defmodule PrisonRideshare.PersonCalendarTest do
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshareWeb.{Institution, Person, Ride, Commitment, Slot}
  alias PrisonRideshare.Repo

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "text/calendar")
      |> put_req_header("content-type", "text/calendar")

    {:ok, conn: conn}
  end

  test "lists calendar events for a driver's rides when the token is included", %{conn: conn} do
    institution = Repo.insert!(%Institution{name: "Stony Mountain"})
    driver = Repo.insert!(%Person{name: "Chelsea Manning"})

    ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2017, 1, 15}, {18, 0, 0}}),
        end: Ecto.DateTime.from_erl({{2017, 1, 15}, {20, 0, 0}}),
        institution: institution,
        driver: driver,
        name: "Tom",
        address: "421 Osborne",
        contact: "2877433"
      })

    Repo.insert!(%Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 15}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 15}, {20, 0, 0}}),
      combined_with: ride,
      name: "Tina",
      address: "414 Osborne",
      contact: "287878"
    })

    different_parent_ride =
      Repo.insert!(%Ride{
        start: Ecto.DateTime.from_erl({{2017, 1, 16}, {11, 0, 0}}),
        end: Ecto.DateTime.from_erl({{2017, 1, 16}, {13, 0, 0}}),
        institution: institution,
        driver: driver,
        name: "Tom",
        address: "421 Osborne",
        contact: "2877433"
      })

    Repo.insert!(%Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 16}, {11, 15, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 16}, {13, 15, 0}}),
      combined_with: different_parent_ride,
      name: "Tina",
      address: "414 Osborne",
      contact: "287878"
    })

    Repo.insert!(%Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 16}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 16}, {20, 0, 0}}),
      enabled: false,
      driver: driver
    })

    # Repo.insert! %Ride{
    #   distance: 77
    # }

    Repo.insert!(%Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 17}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 17}, {20, 0, 0}}),
      institution: institution,
      driver: driver,
      address: "421 Osborne"
    })

    Repo.insert!(%Ride{
      name: "Tom",
      address: "421 Osborne",
      contact: "2877433"
    })

    committed_slot =
      Repo.insert!(%Slot{
        start: Ecto.DateTime.from_erl({{2017, 12, 8}, {13, 0, 0}}),
        end: Ecto.DateTime.from_erl({{2017, 12, 8}, {17, 0, 0}})
      })

    Repo.insert!(%Commitment{
      slot_id: committed_slot.id,
      person_id: driver.id
    })

    conn = get(conn, person_path(conn, :calendar, driver.id, secret: driver.calendar_secret))
    assert response_content_type(conn, :calendar)

    assert response(conn, 200) == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           BEGIN:VEVENT
           DESCRIPTION:Tom\\n421 Osborne\\n2877433\\n\\n\\nTina\\n414 Osborne\\n287878\\n
           DTEND;TZID=Etc/UTC:20170115T200000
           DTSTART;TZID=Etc/UTC:20170115T180000
           LOCATION:421 Osborne\\, 414 Osborne
           SUMMARY:Visit to Stony Mountain
           END:VEVENT
           BEGIN:VEVENT
           DESCRIPTION:Tom\\n421 Osborne\\n2877433\\n\\n\\nTina\\n414 Osborne\\n287878\\n
           DTEND;TZID=Etc/UTC:20170116T131500
           DTSTART;TZID=Etc/UTC:20170116T110000
           LOCATION:421 Osborne\\, 414 Osborne
           SUMMARY:Visit to Stony Mountain
           END:VEVENT
           BEGIN:VEVENT
           DESCRIPTION:\\n\\n\\n
           DTEND;TZID=Etc/UTC:20170116T200000
           DTSTART;TZID=Etc/UTC:20170116T180000
           LOCATION:
           SUMMARY:CANCELLED Visit to missing institution
           END:VEVENT
           BEGIN:VEVENT
           DESCRIPTION:\\n421 Osborne\\n\\n
           DTEND;TZID=Etc/UTC:20170117T200000
           DTSTART;TZID=Etc/UTC:20170117T180000
           LOCATION:421 Osborne
           SUMMARY:Visit to Stony Mountain
           END:VEVENT
           BEGIN:VEVENT
           DTEND;TZID=Etc/UTC:20171208T170000
           DTSTART;TZID=Etc/UTC:20171208T130000
           SUMMARY:Prison rideshare slot commitment
           END:VEVENT
           END:VCALENDAR
           """
  end

  test "returns a 401 when the secret is wrong", %{conn: conn} do
    driver = Repo.insert!(%Person{name: "Chelsea Manning"})
    conn = get(conn, person_path(conn, :calendar, driver.id))

    assert json_response(conn, 401) == %{
             "jsonapi" => %{"version" => "1.0"},
             "errors" => [%{"title" => "Unauthorized", "code" => 401}]
           }
  end
end
