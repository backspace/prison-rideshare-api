defmodule PrisonRideshare.Guardian.AuthErrorHandler do
  use PrisonRideshareWeb, :controller

  def auth_error(conn, {failure_type, reason}, _opts) do
    status =
      case failure_type do
        :invalid_token -> 401
        :unauthenticated -> 401
        :unauthorized -> 403
        :no_resource_found -> 400
      end

    conn
    |> put_status(status)
    |> render(PrisonRideshareWeb.ErrorView, "#{status}.json")
  end
end
