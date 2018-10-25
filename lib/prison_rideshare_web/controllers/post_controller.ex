defmodule PrisonRideshareWeb.PostController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.Post
  alias JaSerializer.Params

  plug(:scrub_params, "data" when action in [:create, :update])

  def index(conn, _params) do
    posts = Repo.all(Post)
    render(conn, "index.json-api", data: posts)
  end
end
