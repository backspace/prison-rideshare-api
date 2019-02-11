defmodule PrisonRideshareWeb.UserControllerTest do
  use PrisonRideshareWeb.ConnCase
  use Bamboo.Test

  import Mock

  alias PrisonRideshareWeb.User
  alias PrisonRideshare.Repo

  @valid_attrs %{admin: false}

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> auth_as_admin

    {:ok, conn: conn}
  end

  defp relationships do
    %{}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, user_path(conn, :index))

    [user | _] = json_response(conn, 200)["data"]
    assert user |> Map.get("attributes") |> Map.get("admin")
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert!(%User{admin: true})
    conn = get(conn, user_path(conn, :show, user))
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{user.id}"
    assert data["type"] == "user"
    assert data["attributes"]["email"] == user.email
    assert data["attributes"]["admin"] == user.admin
  end

  test "shows the current user", %{conn: conn} do
    conn = get(conn, user_path(conn, :current))
    data = json_response(conn, 200)["data"]

    assert data["attributes"]["email"] == "test@example.com"
    assert data["attributes"]["admin"]
  end

  test "returns a 401 if the token is unrecognised" do
    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> put_req_header("authorization", "Bearer XXX")

    conn = get(conn, user_path(conn, :current))
    assert json_response(conn, 401)
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn ->
      get(conn, user_path(conn, :show, "00000000-0000-0000-0000-000000000000"))
    end)
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn =
      post(conn, user_path(conn, :create), %{
        "meta" => %{},
        "data" => %{
          "type" => "users",
          "attributes" => %{
            admin: true,
            email: "another@example.com",
            password: "a password",
            "password-confirmation": "a password"
          },
          "relationships" => relationships()
        }
      })

    user = Repo.get_by(User, %{email: "another@example.com"})

    assert json_response(conn, 201)["data"]["id"] == user.id
    assert json_response(conn, 201)["data"]["attributes"]["email"] == "another@example.com"
    refute json_response(conn, 201)["data"]["attributes"]["admin"]
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, user_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "users",
        "attributes" => %{
          "password" => "abc",
          "password-confirmation" => "def"
        },
        "relationships" => relationships()
      }
    })
  
    assert json_response(conn, 422)["errors"] == [
      %{
        "detail" => "Password confirmation does not match confirmation",
        "source" => %{"pointer" => "/data/attributes/password-confirmation"},
        "title" => "does not match confirmation"
      },
      %{
        "detail" => "Password should be at least 8 character(s)",
        "source" => %{"pointer" => "/data/attributes/password"},
        "title" => "should be at least 8 character(s)"
      },
      %{
        "detail" => "Email can't be blank",
        "source" => %{"pointer" => "/data/attributes/email"},
        "title" => "can't be blank"
      }
    ]
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    user = Repo.insert!(%User{})

    conn =
      put(conn, user_path(conn, :update, user), %{
        "meta" => %{},
        "data" => %{
          "type" => "users",
          "id" => user.id,
          "attributes" => @valid_attrs,
          "relationships" => relationships()
        }
      })

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
    user = Repo.insert!(%User{})
    conn = delete(conn, user_path(conn, :delete, user))
    assert response(conn, 204)
    refute Repo.get(User, user.id)
  end

  test "sends a reset email when resetting a password" do
    user = Repo.insert!(%User{email: "user@example.com"})
    user_id = user.id
    token = "token for #{user.email}"

    with_mock Phoenix.Token, [sign: fn(PrisonRideshareWeb.Endpoint, "reset salt", user_id) -> token end] do
      conn = post(conn, user_path(conn, :reset, email: "user@example.com"))

      assert_delivered_email(PrisonRideshare.Email.reset(user, token))
      assert response(conn, 204)
    end
  end
end
