defmodule PrisonRideshareWeb.RegistrationControllerTest do
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshareWeb.User

  @valid_attrs %{
    email: "mike@example.com",
    password: "fqhi12hrrfasf",
    "password-confirmation": "fqhi12hrrfasf"
  }

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn =
      post(conn, Routes.registration_path(conn, :create), %{
        data: %{type: "users", attributes: @valid_attrs}
      })

    user = Repo.get_by(User, %{email: @valid_attrs[:email]})
    assert json_response(conn, 201)["data"]["id"] == user.id

    [version] = Repo.all(PaperTrail.Version)
    assert version.event == "insert"
    refute version.item_changes["password"]
    refute version.item_changes["password_confirmation"]
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn =
      post(conn, Routes.registration_path(conn, :create), %{
        data: %{
          type: "users",
          attributes: %{
            email: "hey@example.com",
            password: "abcdefghi",
            "password-confirmation": "abcdefghijkl"
          }
        }
      })

    assert json_response(conn, 422)["errors"] == [
             %{
               "detail" => "Password confirmation does not match confirmation",
               "source" => %{"pointer" => "/data/attributes/password-confirmation"},
               "title" => "does not match confirmation"
             }
           ]

    assert length(Repo.all(User)) == 0
  end
end
