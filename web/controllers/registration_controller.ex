defmodule PrisonRideshare.RegistrationController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.User

  def create(conn, %{"data" => %{"type" => "users",
  	"attributes" => %{"email" => email,
  	  "password" => password,
  	  "password_confirmation" => password_confirmation}}}) do

    changeset = User.changeset %User{}, %{email: email,
      password_confirmation: password_confirmation,
      password: password}

    case Repo.insert changeset do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render(PrisonRideshare.UserView, "show.json-api", data: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PrisonRideshare.ChangesetView, "show.json-api", data: changeset)
    end
  end

  # FIXME this is only here because I‘ve given up on making the accompanying test submit with dash instead of underscore’
  def create(conn, %{"data" => %{"type" => "users",
    "attributes" => %{"email" => email,
      "password" => password,
      "password-confirmation" => password_confirmation}}}) do
    create(conn, %{"data" => %{"type" => "users",
      "attributes" => %{"email" => email,
        "password" => password, "password_confirmation" => password_confirmation}}})
  end
end
