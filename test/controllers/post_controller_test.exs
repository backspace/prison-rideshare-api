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

  test "lists all posts with unread status", %{conn: conn} do
    logged_in_user = Repo.one(User)

    user = Repo.insert!(%User{admin: true})

    post =
      Repo.insert!(%Post{
        content: "hello read",
        readings: [logged_in_user.id],
        updated_at: Ecto.DateTime.from_erl({{2018, 7, 6}, {9, 29, 1}}),
        inserted_at: Ecto.DateTime.from_erl({{2018, 7, 6}, {9, 29, 0}}),
        poster: user
      })

    unread_post =
      Repo.insert!(%Post{
        content: "hello unread",
        readings: [user.id],
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
                 "content" => "hello read",
                 "unread" => false,
                 "updated-at" => "2018-07-06T09:29:01.000000Z",
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
             },
             %{
               "id" => unread_post.id,
               "type" => "post",
               "attributes" => %{
                 "content" => "hello unread",
                 "unread" => true,
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
          }
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
          "attributes" => %{}
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

  test "updates and renders chosen resource when data is valid and user is poster, ignoring attempt to change poster",
       %{conn: conn} do
    [user] = Repo.all(User)

    post =
      Repo.insert!(%Post{
        content: "old content",
        poster: user
      })

    other_user = Repo.insert!(%User{admin: true})

    conn =
      put(conn, post_path(conn, :update, post), %{
        "meta" => %{},
        "data" => %{
          "type" => "posts",
          "id" => post.id,
          "attributes" => %{
            "content" => "new content"
          },
          "relationships" => %{
            "poster" => %{
              "data" => %{
                "type" => "user",
                "id" => other_user.id
              }
            }
          }
        }
      })

    post = Repo.one(Post)

    attributes = json_response(conn, 200)["data"]["attributes"]
    assert attributes["content"] == "new content"

    assert post.poster_id == user.id

    [version] = Repo.all(PaperTrail.Version)
    assert version.event == "update"
    assert version.item_changes["content"] == "new content"
    assert version.meta["ip"] == "127.0.0.1"
  end

  test "rejects update when user is not poster", %{conn: conn} do
    other_user = Repo.insert!(%User{})

    post =
      Repo.insert!(%Post{
        content: "old content",
        poster: other_user
      })

    conn =
      put(conn, post_path(conn, :update, post), %{
        "meta" => %{},
        "data" => %{
          "type" => "posts",
          "id" => post.id,
          "attributes" => %{
            "content" => "new content"
          }
        }
      })

    post = Repo.one(Post)

    attributes = json_response(conn, 403)
    refute attributes["content"] == "new content"
    refute post.content == "new content"

    assert Repo.all(PaperTrail.Version) == []
  end

  test "can delete a post", %{conn: conn} do
    [user] = Repo.all(User)

    post =
      Repo.insert!(%Post{
        content: "old content",
        poster: user
      })

    conn =
      conn
      |> delete(post_path(conn, :delete, post))

    assert response(conn, 204)
    assert Repo.all(Post) == []

    [version] = Repo.all(PaperTrail.Version)
    assert version.event == "delete"
    assert version.item_changes["content"] == "old content"
  end

  test "cannot delete a commitment for someone else", %{conn: conn} do
    other_user = Repo.insert!(%User{})

    post =
      Repo.insert!(%Post{
        content: "old content",
        poster: other_user
      })

    conn =
      conn
      |> delete(post_path(conn, :delete, post))

    assert json_response(conn, 401) == %{
             "jsonapi" => %{"version" => "1.0"},
             "errors" => [%{"title" => "Unauthorized", "code" => 401}]
           }

    assert length(Repo.all(Post)) == 1
  end

  test "marks a post as read", %{conn: conn} do
    [user] = Repo.all(User)

    post = Repo.insert!(%Post{})

    conn = post(conn, post_path(conn, :read_post, post))

    post = Repo.one(Post)

    assert user.id in post.readings
    refute json_response(conn, 200)["data"]["attributes"]["unread"]
  end

  test "does not double-store a post reading", %{conn: conn} do
    [user] = Repo.all(User)

    post =
      Repo.insert!(%Post{
        readings: [user.id]
      })

    conn = post(conn, post_path(conn, :read_post, post))

    post = Repo.one(Post)

    assert [user.id] == post.readings
  end

  test "marks a post as unread", %{conn: conn} do
    [user] = Repo.all(User)

    post =
      Repo.insert!(%Post{
        readings: [user.id]
      })

    conn = delete(conn, post_path(conn, :unread_post, post))

    post = Repo.one(Post)

    refute user.id in post.readings
    assert json_response(conn, 200)["data"]["attributes"]["unread"]
  end
end
