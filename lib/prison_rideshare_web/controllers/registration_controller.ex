defmodule PrisonRideshareWeb.RegistrationController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.User

  def create(conn, %{
        "data" => %{
          "type" => "users",
          "attributes" => %{
            "email" => email,
            "password" => password,
            "password_confirmation" => password_confirmation
          }
        }
      }) do
    changeset =
      User.changeset(%User{}, %{
        email: email,
        password_confirmation: password_confirmation,
        password: password
      })

    case PaperTrail.insert(changeset, version_information(conn)) do
      {:ok, %{model: user}} ->
        conn
        |> put_status(:created)
        |> render(PrisonRideshareWeb.UserView, "show.json-api", data: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PrisonRideshareWeb.ChangesetView, :errors, data: changeset)
    end
  end

  # FIXME this is only here because I‘ve given up on making the accompanying test submit with dash instead of underscore’
  def create(conn, %{
        "data" => %{
          "type" => "users",
          "attributes" => %{
            "email" => email,
            "password" => password,
            "password-confirmation" => password_confirmation
          }
        }
      }) do
    create(conn, %{
      "data" => %{
        "type" => "users",
        "attributes" => %{
          "email" => email,
          "password" => password,
          "password_confirmation" => password_confirmation
        }
      }
    })
  end
end
