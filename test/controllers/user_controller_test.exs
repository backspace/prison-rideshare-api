defmodule PrisonRideshare.UserControllerTest do
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.User
  alias PrisonRideshare.Repo

  @valid_attrs %{admin: false}

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
    conn = get conn, user_path(conn, :index)

    [user | _] = json_response(conn, 200)["data"]
    assert user |> Map.get("attributes") |> Map.get("admin")
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{admin: true}
    conn = get conn, user_path(conn, :show, user)
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{user.id}"
    assert data["type"] == "user"
    assert data["attributes"]["email"] == user.email
    assert data["attributes"]["admin"] == user.admin
  end

  test "shows the current user", %{conn: conn} do
    conn = get conn, user_path(conn, :current)
    data = json_response(conn, 200)["data"]

    assert data["attributes"]["email"] == "test@example.com"
    assert data["attributes"]["admin"]
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, "00000000-0000-0000-0000-000000000000")
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "users",
        "attributes" => @valid_attrs,
        "relationships" => relationships()
      }
    }

    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(User, @valid_attrs)
  end

  # FIXME will this ever happen?
  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, user_path(conn, :create), %{
  #     "meta" => %{},
  #     "data" => %{
  #       "type" => "user",
  #       "attributes" => @invalid_attrs,
  #       "relationships" => relationships
  #     }
  #   }
  #
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), %{
      "meta" => %{},
      "data" => %{
        "type" => "users",
        "id" => user.id,
        "attributes" => @valid_attrs,
        "relationships" => relationships()
      }
    }

    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(User, @valid_attrs)
  end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = put conn, user_path(conn, :update, user), %{
  #     "meta" => %{},
  #     "data" => %{
  #       "type" => "user",
  #       "id" => user.id,
  #       "attributes" => @invalid_attrs,
  #       "relationships" => relationships()
  #     }
  #   }
  #
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  test "deletes chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = delete conn, user_path(conn, :delete, user)
    assert response(conn, 204)
    refute Repo.get(User, user.id)
  end

end
