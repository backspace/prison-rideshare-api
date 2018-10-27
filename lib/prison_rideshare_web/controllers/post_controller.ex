defmodule PrisonRideshareWeb.PostController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.Post
  alias JaSerializer.Params

  plug(:scrub_params, "data" when action in [:create, :update])

  def index(conn, _params) do
    posts = Repo.all(Post)
    |> Repo.preload(:poster)

    render(conn, "index.json-api", data: posts)
  end

  def create(conn, %{"data" => data = %{"type" => "posts", "attributes" => _params}}) do
    resource = Guardian.Plug.current_resource(conn)

    user =
      case resource do
        %PrisonRideshareWeb.User{} -> resource
        _ -> nil
      end

    params =
      Params.to_attributes(data)
      |> Map.put("poster_id", user.id)

    changeset = Post.changeset(%Post{poster: user}, params)

    case PaperTrail.insert(changeset, version_information(conn)) do
      {:ok, %{model: post}} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", post_path(conn, :show, post))
        |> render("show.json-api", data: post)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def update(conn, %{
        "id" => id,
        "data" => data = %{"type" => "posts", "attributes" => _params}
      }) do
    post = Repo.get!(Post, id)
    |> Repo.preload(:poster)

    resource = Guardian.Plug.current_resource(conn)

    user_id =
      case resource do
        %PrisonRideshareWeb.User{} -> resource.id
        _ -> nil
      end

    if post.poster_id == user_id do
      data_without_relationships = Map.delete(data, "relationships")

      changeset = Post.changeset(post, Params.to_attributes(data_without_relationships))

      case PaperTrail.update(changeset, version_information(conn)) do
        {:ok, %{model: post}} ->
          render(conn, "show.json-api", data: post)

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(:errors, data: changeset)
      end
    else
      conn
      |> put_status(:forbidden)
      |> render(PrisonRideshareWeb.ErrorView, "403.json")
    end
  end
end
