defmodule PrisonRideshareWeb.SessionControllerTest do
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshareWeb.User

  setup do
    user = User.changeset %User{}, %{
      email: "hello@example.com",
      password_confirmation: "aaaaaaaaa",
      password: "aaaaaaaaa"
    }

    Repo.insert! user

    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "returns a token when the password matches the user", %{conn: conn} do
    conn = post conn, login_path(conn, :create), %{
      grant_type: "password",
      username: "hello@example.com",
      password: "aaaaaaaaa"
    }

    assert json_response(conn, 200)["access_token"]
  end

  test "returns a 401 when the password is wrong", %{conn: conn} do
    conn = post conn, login_path(conn, :create), %{
      grant_type: "password",
      username: "hello@example.com",
      password: "bbbbbbbbb"
    }

    assert json_response(conn, 401) == %{
      "jsonapi" => %{"version" => "1.0"},
      "errors" => [%{"title" => "Unauthorized", "code" => 401}]
    }
  end

  test "returns a 401 when the user doesn't exist", %{conn: conn} do
    conn = post conn, login_path(conn, :create), %{
      grant_type: "password",
      username: "x@example.com",
      password: "bbbbbbbbb"
    }

    assert json_response(conn, 401) == %{
      "jsonapi" => %{"version" => "1.0"},
      "errors" => [%{"title" => "Unauthorized", "code" => 401}]
    }
  end

  test "fails when the grant type is not password", %{conn: conn} do
    try do
      post conn, login_path(conn, :create), %{grant_type: "jorts"}
    catch
      _ -> assert true
    end
  end
end
