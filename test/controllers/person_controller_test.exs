defmodule PrisonRideshareWeb.PersonControllerTest do
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshareWeb.Person
  alias PrisonRideshare.Repo

  @valid_attrs %{name: "some content", email: "hello@example.com", mobile: "5145551313"}
  @invalid_attrs %{name: "aname", email: "jorty@example.com"}

  setup do
    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> put_req_header("user-agent", "HELLO")
      |> auth_as_admin

    {:ok, conn: conn}
  end

  defp relationships do
    %{}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, person_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    person = Repo.insert! %Person{name: "a", email: "b", mobile: "c", landline: "d", notes: "e"}
    conn = get conn, person_path(conn, :show, person)
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{person.id}"
    assert data["type"] == "person"

    attributes = data["attributes"]
    assert attributes["name"] == person.name
    assert attributes["email"] == person.email
    assert attributes["mobile"] == person.mobile
    assert attributes["landline"] == person.landline
    assert attributes["notes"] == person.notes
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, person_path(conn, :show, "00000000-0000-0000-0000-000000000000")
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, person_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "people",
        "attributes" => @valid_attrs,
        "relationships" => relationships()
      }
    }

    person = Repo.get_by(Person, @valid_attrs)
    assert json_response(conn, 201)["data"]["id"] == person.id

    attributes = json_response(conn, 201)["data"]["attributes"]
    assert attributes["name"] == "some content"
    assert attributes["email"] == @valid_attrs[:email]
    assert attributes["mobile"] == @valid_attrs[:mobile]

    [user] = Repo.all PrisonRideshareWeb.User

    [version] = Repo.all PaperTrail.Version
    assert version.event == "insert"
    assert version.item_changes["name"] == "some content"
    assert version.meta["ip"] == "127.0.0.1"
    assert version.meta["user-agent"] == "HELLO"
    assert version.originator_id == user.id
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, person_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "people",
        "attributes" => @invalid_attrs,
        "relationships" => relationships()
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    person = Repo.insert! %Person{name: "oldname"}
    conn = put conn, person_path(conn, :update, person), %{
      "meta" => %{},
      "data" => %{
        "type" => "people",
        "id" => person.id,
        "attributes" => @valid_attrs,
        "relationships" => relationships()
      }
    }

    person = Repo.get_by(Person, @valid_attrs)

    attributes = json_response(conn, 200)["data"]["attributes"]
    assert attributes["name"] == person.name
    assert attributes["email"] == person.email
    assert attributes["mobile"] == person.mobile

    [version] = Repo.all PaperTrail.Version
    assert version.event == "update"
    assert version.item_changes["name"] == "some content"
    assert version.meta["ip"] == "127.0.0.1"
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    person = Repo.insert! %Person{}
    conn = put conn, person_path(conn, :update, person), %{
      "meta" => %{},
      "data" => %{
        "type" => "people",
        "id" => person.id,
        "attributes" => @invalid_attrs,
        "relationships" => relationships()
      }
    }

    # FIXME the lack of control over title vs detail results in this unfortunate wording
    assert json_response(conn, 422)["errors"] == [
      %{"detail" => "Landline or mobile must be present", "source" => %{"pointer" => "/data/attributes/landline"}, "title" => "or mobile must be present"},
      %{"detail" => "Mobile or landline must be present", "source" => %{"pointer" => "/data/attributes/mobile"}, "title" => "or landline must be present"}
    ]

    assert Repo.all(PaperTrail.Version) == []
  end

  test "deletes chosen resource", %{conn: conn} do
    person = Repo.insert! %Person{name: "deletedname"}
    conn = delete conn, person_path(conn, :delete, person)
    assert response(conn, 204)
    refute Repo.get(Person, person.id)

    [version] = Repo.all PaperTrail.Version
    assert version.event == "delete"
    assert version.item_changes["name"] == "deletedname"
    assert version.meta["ip"] == "127.0.0.1"
  end

end
