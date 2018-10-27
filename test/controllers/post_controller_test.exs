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

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn =
      post(conn, post_path(conn, :create), %{
        "meta" => %{},
        "data" => %{
          "type" => "posts",
          "attributes" => %{
            "content" => "hello"
          },
        }
      })

    user = Repo.one(User)
    [post] = Repo.all(Post)

    assert json_response(conn, 201)["data"]["id"] == post.id

    attributes = json_response(conn, 201)["data"]["attributes"]
    assert attributes["content"] == "hello"

    assert json_response(conn, 201)["data"]["relationships"]["poster"]["data"]["id"] == user.id

    [version] = Repo.all(PaperTrail.Version)
    assert version.event == "insert"
    assert version.item_changes["content"] == "hello"
    assert version.originator_id == user.id
  end

  test "does not create resource or version and renders errors when data is invalid", %{
    conn: conn
  } do
    conn =
      post(conn, post_path(conn, :create), %{
        "meta" => %{},
        "data" => %{
          "type" => "posts",
          "attributes" => %{
          },
        }
      })

    assert json_response(conn, 422)["errors"] == [
             %{
               "detail" => "Content can't be blank",
               "source" => %{"pointer" => "/data/attributes/content"},
               "title" => "can't be blank"
             }
           ]

    assert Repo.all(Post) == []
    assert Repo.all(PaperTrail.Version) == []
  end

  test "updates and renders chosen resource when data is valid and user is poster", %{conn: conn} do
    [user] = Repo.all(User)
    post = Repo.insert!(%Post{
      content: "old content",
      poster: user,
    })

    conn =
      put(conn, post_path(conn, :update, post), %{
        "meta" => %{},
        "data" => %{
          "type" => "posts",
          "id" => post.id,
          "attributes" => %{
            "content" => "new content"
          },
        }
      })

    post = Repo.one(Post)

    attributes = json_response(conn, 200)["data"]["attributes"]
    assert attributes["content"] == "new content"

    [version] = Repo.all(PaperTrail.Version)
    assert version.event == "update"
    assert version.item_changes["content"] == "new content"
    assert version.meta["ip"] == "127.0.0.1"
  end

  test "rejects update when user is not poster", %{conn: conn} do
    other_user = Repo.insert!(%User{})
    post = Repo.insert!(%Post{
      content: "old content",
      poster: other_user,
    })

    conn =
      put(conn, post_path(conn, :update, post), %{
        "meta" => %{},
        "data" => %{
          "type" => "posts",
          "id" => post.id,
          "attributes" => %{
            "content" => "new content"
          },
        }
      })

    post = Repo.one(Post)

    attributes = json_response(conn, 403)
    refute attributes["content"] == "new content"

    assert Repo.all(PaperTrail.Version) == []
  end
end
