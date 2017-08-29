defmodule PrisonRideshare.PersonControllerTest do
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.Person
  alias PrisonRideshare.Repo

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  setup do
    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
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
    person = Repo.insert! %Person{}
    conn = get conn, person_path(conn, :show, person)
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{person.id}"
    assert data["type"] == "person"
    assert data["attributes"]["name"] == person.name
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
    assert json_response(conn, 201)["data"]["attributes"]["name"] == "some content"
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
    person = Repo.insert! %Person{}
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
    assert json_response(conn, 200)["data"]["id"] == person.id
    assert json_response(conn, 200)["data"]["attributes"]["name"] == "some content"
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

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    person = Repo.insert! %Person{}
    conn = delete conn, person_path(conn, :delete, person)
    assert response(conn, 204)
    refute Repo.get(Person, person.id)
  end

end
