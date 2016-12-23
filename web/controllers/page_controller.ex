defmodule PrisonRideshare.PageController do
  use PrisonRideshare.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
