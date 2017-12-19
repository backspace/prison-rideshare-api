defmodule PrisonRideshareWeb.SessionController do
  use PrisonRideshareWeb, :controller

  import Ecto.Query, only: [where: 2]
  import Comeonin.Bcrypt
  require Logger

  alias PrisonRideshareWeb.User

  def create(conn, %{"grant_type" => "password",
    "username" => username,
    "password" => password}) do

    try do
      # Attempt to retrieve exactly one user from the DB, whose
      #   email matches the one provided with the login request
      user = User
      |> where(email: ^username)
      |> Repo.one!
      cond do

        checkpw(password, user.password_hash) ->
          # Successful login
          Logger.info "User " <> username <> " just logged in"
          # Encode a JWT
          { :ok, jwt, _} = PrisonRideshare.Guardian.encode_and_sign(user)
          conn
          |> json(%{access_token: jwt}) # Return token to the client

        true ->
          # Unsuccessful login
          Logger.warn "User " <> username <> " just failed to login"
          conn
          |> put_status(401)
          |> render(PrisonRideshareWeb.ErrorView, "401.json") # 401
      end
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging
        Logger.error "Unexpected error while attempting to login user " <> username
        conn
        |> put_status(401)
        |> render(PrisonRideshareWeb.ErrorView, "401.json") # 401
    end
  end

  def create(_conn, %{"grant_type" => _}) do
    ## Handle unknown grant type
    throw "Unsupported grant_type"
  end
end
