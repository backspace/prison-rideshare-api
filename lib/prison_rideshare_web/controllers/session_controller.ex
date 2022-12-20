defmodule PrisonRideshareWeb.SessionController do
  use PrisonRideshareWeb, :controller

  import Ecto.Query, only: [where: 2]
  import Comeonin.Bcrypt
  require Logger

  alias PrisonRideshareWeb.User

  def create(conn, %{"grant_type" => "password", "username" => username, "password" => password}) do
    try do
      # Attempt to retrieve exactly one user from the DB, whose
      #   email matches the one provided with the login request
      user =
        User
        |> where(email: ^username)
        |> Repo.one!()

      cond do
        checkpw(password, user.password_hash) ->
          # Successful login
          Logger.info("User " <> username <> " just logged in")
          # Encode a JWT
          {:ok, jwt, _} = PrisonRideshare.Guardian.encode_and_sign(user)
          # Return token to the client
          conn
          |> json(%{access_token: jwt})

        true ->
          # Unsuccessful login
          Logger.warn("User " <> username <> " just failed to login")
          # 401
          conn
          |> put_status(401)
          |> put_view(PrisonRideshareWeb.ErrorView)
          |> render("401.json")

      end
    rescue
      e ->
        # Print error to the console for debugging
        IO.inspect(e)
        Logger.error("Unexpected error while attempting to login user " <> username)
        # 401
        conn
        |> put_status(401)
        |> put_view(PrisonRideshareWeb.ErrorView)
        |> render("401.json")
    end
  end

  def create(_conn, %{"grant_type" => _}) do
    ## Handle unknown grant type
    throw("Unsupported grant_type")
  end
end
