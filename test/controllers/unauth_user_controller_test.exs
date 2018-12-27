defmodule PrisonRideshareWeb.UserControllerTest do
    use PrisonRideshareWeb.ConnCase
    use Bamboo.Test

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
  end
  