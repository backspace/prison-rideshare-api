defmodule PrisonRideshareWeb.SlotControllerTest do
  use PrisonRideshareWeb.ConnCase
  use Bamboo.Test

  alias PrisonRideshareWeb.Slot
  alias PrisonRideshare.Repo

  setup do
    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "lists all slots", %{conn: conn} do
    later = Repo.insert! %Slot{
      start: Ecto.DateTime.from_erl({{2017, 12, 10}, {13, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 12, 10}, {17, 0, 0}})
    }

    earlier = Repo.insert! %Slot{
      start: Ecto.DateTime.from_erl({{2017, 12, 8}, {13, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 12, 8}, {17, 0, 0}})
    }

    conn = get conn, slot_path(conn, :index)
    assert json_response(conn, 200)["data"] == [%{
      "id" => later.id,
      "type" => "slot",
      "attributes" => %{
        "start" => "2017-12-10T13:00:00.000000Z",
        "end" => "2017-12-10T17:00:00.000000Z"
      }},
      %{
        "id" => earlier.id,
        "type" => "slot",
        "attributes" => %{
          "start" => "2017-12-08T13:00:00.000000Z",
          "end" => "2017-12-08T17:00:00.000000Z"
        }
    }]
  end
end
