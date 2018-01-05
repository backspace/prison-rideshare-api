defmodule PrisonRideshareWeb.PersonSessionControllerTest do
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshareWeb.Person

  setup do
    person = Person.changeset %Person{}, %{
      name: "A person",
      email: "hello@example.com"
    }

    Repo.insert! person

    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "returns a token when magic token matches", %{conn: conn} do
    [person] = Repo.all(Person)
    {:ok, magic_token, _claims} = PrisonRideshare.PersonGuardian.encode_magic(person)

    conn = post conn, person_login_path(conn, :create), %{
      grant_type: "magic",
      token: magic_token
    }

    assert json_response(conn, 200)["access_token"]
  end

  test "returns a 401 when the token is wrong", %{conn: conn} do
    conn = post conn, person_login_path(conn, :create), %{
      grant_type: "magic",
      token: "jorts"
    }

    assert json_response(conn, 401) == %{
      "jsonapi" => %{"version" => "1.0"},
      "errors" => [%{"title" => "Unauthorized", "code" => 401}]
    }
  end

  test "returns the person an access token belongs to", %{conn: conn} do
    [person] = Repo.all(Person)
    {:ok, magic_token, _claims} = PrisonRideshare.PersonGuardian.encode_magic(person)
    {:ok, access_token, _claims} = PrisonRideshare.PersonGuardian.exchange_magic(magic_token)

    conn = get(conn, person_identify_path(conn, :show, token: access_token))

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
end
