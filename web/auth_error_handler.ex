defmodule PrisonRideshare.AuthErrorHandler do
  use PrisonRideshare.Web, :controller

  def unauthenticated(conn, params) do
  conn
   |> put_status(401)
   |> render(PrisonRideshare.ErrorView, "401.json")
  end

  def unauthorized(conn, params) do
  conn
   |> put_status(403)
   |> render(PrisonRideshare.ErrorView, "403.json")
  end
end
