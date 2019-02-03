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
  
      {:ok, conn: conn}
    end
  
    defp relationships do
      %{}
    end
  
    test "refuses to list all users when unauthenticated", %{conn: conn} do
      conn = get(conn, user_path(conn, :index))
      assert json_response(conn, 401)
    end
  
    test "refuses to show a resource when unauthenticated", %{conn: conn} do
      user = Repo.insert!(%User{admin: true})
      conn = get(conn, user_path(conn, :show, user))
      assert json_response(conn, 401)
    end

    test "refuses to update a resource without a token", %{conn: conn} do
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
  
      assert json_response(conn, 401)
    end

    test "updates a user’s password when the reset token is valid", %{conn: conn} do
      user = Repo.insert!(%User{email: "user@example.com"})
      user_id = user.id

      token = "TOKEN!"

      with_mock Phoenix.Token, [verify: fn(PrisonRideshareWeb.Endpoint, "reset salt", token) -> {:ok, user_id} end] do
        conn =
          put(conn, user_path(conn, :update, token), %{
            "data" => %{
              "type" => "users",
              "attributes" => %{
                "password" => "abcdef",
                "password-confirmation" => "abcdef"
              }
            }
          })
        
        user = Repo.get_by(User, %{email: @valid_attrs[:email]})
        assert json_response(conn, 201)["data"]["id"] == user.id
    
        [version] = Repo.all(PaperTrail.Version)
        assert version.event == "insert"
        refute version.item_changes["password"]
        refute version.item_changes["password_confirmation"]
      end
      end
  