defmodule PrisonRideshareWeb.AuthErrorHandler do
  use PrisonRideshareWeb, :controller

  def unauthenticated(conn, _params) do
  conn
   |> put_status(401)
   |> render(PrisonRideshareWeb.ErrorView, "401.json")
  end

  def unauthorized(conn, _params) do
  conn
   |> put_status(403)
   |> render(PrisonRideshareWeb.ErrorView, "403.json")
  end
end
