defmodule PrisonRideshareWeb.PersonSessionControllerTest do
  use PrisonRideshareWeb.ConnCase

  import Mock

  alias PrisonRideshareWeb.Person

  setup do
    person =
      Person.changeset(%Person{}, %{
        name: "A person",
        email: "hello@example.com",
        notes: "These should be secret",
        self_notes: "These are not secret",
        mobile: "5551313"
      })

    Repo.insert!(person)

    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "returns a token when magic token matches", %{conn: conn} do
    [person] = Repo.all(Person)
    {:ok, magic_token, _claims} = PrisonRideshare.PersonGuardian.encode_magic(person)

    conn =
      post(conn, Routes.person_login_path(conn, :create), %{
        grant_type: "magic",
        token: magic_token
      })

    assert json_response(conn, 200)["access_token"]
  end

  test "returns a 401 when the token is wrong", %{conn: conn} do
    conn =
      post(conn, Routes.person_login_path(conn, :create), %{
        grant_type: "magic",
        token: "jorts"
      })

    assert json_response(conn, 401) == %{
             "jsonapi" => %{"version" => "1.0"},
             "errors" => [%{"title" => "Unauthorized", "code" => 401}]
           }
  end

  # It seems to not be possible to construct an expired token, as only positive numbers are accepted
  test "returns a 401 when the token is expired", %{conn: conn} do
    with_mock PrisonRideshare.PersonGuardian, exchange_magic: fn _ -> {:error, :token_expired} end do
      conn =
        post(conn, Routes.person_login_path(conn, :create), %{
          grant_type: "magic",
          token: "anything"
        })

      assert json_response(conn, 401) == %{
               "jsonapi" => %{"version" => "1.0"},
               "errors" => [
                 %{
                   "title" => "Unauthorized",
                   "code" => 401,
                   "detail" => "That token is expired. Did you click an old link?"
                 }
               ]
             }
    end
  end

  test "returns the person an access token belongs to", %{conn: conn} do
    [person] = Repo.all(Person)
    {:ok, magic_token, _claims} = PrisonRideshare.PersonGuardian.encode_magic(person)
    {:ok, access_token, _claims} = PrisonRideshare.PersonGuardian.exchange_magic(magic_token)

    conn = get(conn, Routes.person_identify_path(conn, :show, token: access_token))

    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{person.id}"
    assert data["type"] == "person"

    attributes = data["attributes"]
    assert attributes["name"] == person.name
    assert attributes["email"] == person.email
    assert attributes["mobile"] == person.mobile
    assert attributes["landline"] == person.landline
    refute attributes["notes"]
    assert attributes["self-notes"] == person.self_notes
    assert attributes["calendar-secret"] == person.calendar_secret
  end

  test "updates a subset and renders the person with their token", %{conn: conn} do
    [person] = Repo.all(Person)
    {:ok, magic_token, _claims} = PrisonRideshare.PersonGuardian.encode_magic(person)
    {:ok, access_token, _claims} = PrisonRideshare.PersonGuardian.exchange_magic(magic_token)

    conn =
      conn
      |> put_req_header("authorization", "Person Bearer #{access_token}")
      |> patch(Routes.person_patch_path(conn, :update), %{
        "data" => %{
          "type" => "people",
          "id" => person.id,
          "attributes" => %{
            "name" => "A new name",
            "email" => "newemail@example.com",
            "notes" => "New notes?",
            "mobile" => "2045551313",
            "self-notes" => "New self notes.",
            "address" => "a new address"
          }
        }
      })

    person = Repo.get!(Person, person.id)

    attributes = json_response(conn, 200)["data"]["attributes"]
    assert attributes["name"] == person.name
    # TODO allow email updates
    assert attributes["email"] == "hello@example.com"
    assert attributes["mobile"] == person.mobile
    assert attributes["medium"] == person.medium
    refute attributes["notes"]
    assert attributes["self-notes"] == "New self notes."
    assert attributes["address"] == "a new address"

    assert person.name == "A new name"
    assert person.notes == "These should be secret"
    assert person.self_notes == "New self notes."
    assert person.address == "a new address"

    [version] = Repo.all(PaperTrail.Version)
    assert version.event == "update"
    # assert version.item_changes["name"] == "some content"
    # assert version.meta["ip"] == "127.0.0.1"
  end

  test "does not update and renders errors when data is invalid", %{conn: conn} do
    [person] = Repo.all(Person)
    {:ok, magic_token, _claims} = PrisonRideshare.PersonGuardian.encode_magic(person)
    {:ok, access_token, _claims} = PrisonRideshare.PersonGuardian.exchange_magic(magic_token)

    conn =
      conn
      |> put_req_header("authorization", "Person Bearer #{access_token}")
      |> patch(Routes.person_patch_path(conn, :update), %{
        "data" => %{
          "type" => "people",
          "id" => person.id,
          "attributes" => %{
            "name" => "",
            "email" => "newemail@example.com",
            "notes" => "New notes?",
            "mobile" => "2045551313"
          }
        }
      })

    assert json_response(conn, 422)["errors"] == [
             %{
               "detail" => "Name can't be blank",
               "source" => %{"pointer" => "/data/attributes/name"},
               "title" => "can't be blank"
             }
           ]

    person = Repo.get!(Person, person.id)
    assert person.name == "A person"
  end
end
