defmodule PrisonRideshareWeb.PostControllerTest do
  use PrisonRideshareWeb.ConnCase
  use Bamboo.Test

  alias PrisonRideshareWeb.{Post, User}
  alias PrisonRideshare.Repo

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> auth_as_admin

    {:ok, conn: conn}
  end

  test "lists all posts", %{conn: conn} do
    user = Repo.insert!(%User{admin: true})

    post =
      Repo.insert!(%Post{
        content: "hello",
        updated_at: Ecto.DateTime.from_erl({{2018, 7, 6}, {9, 29, 0}}),
        inserted_at: Ecto.DateTime.from_erl({{2018, 7, 6}, {9, 29, 0}}),
        poster: user
      })

    conn = get(conn, post_path(conn, :index))

    assert json_response(conn, 200)["data"] == [
             %{
               "id" => post.id,
               "type" => "post",
               "attributes" => %{
                 "content" => "hello",
                 "updated-at" => "2018-07-06T09:29:00.000000Z",
                 "inserted-at" => "2018-07-06T09:29:00.000000Z"
               },
               "relationships" => %{
                 "poster" => %{
                   "data" => %{
                     "type" => "user",
                     "id" => user.id
                   }
                 }
               }
             }
           ]
  end
end
