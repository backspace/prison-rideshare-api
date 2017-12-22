defmodule PrisonRideshareWeb.PersonSessionController do
  use PrisonRideshareWeb, :controller

  def create(conn, %{"grant_type" => "magic", "token" => magic_token}) do
    case PrisonRideshare.PersonGuardian.exchange_magic(magic_token) do
      {:ok, access_token, _claims} -> conn |> json(%{access_token: access_token}) # Return token to the client
    end
  end

  def show(conn, %{"token" => access_token}) do
    {:ok, %{"sub" => "Person:" <> id}} = PrisonRideshare.PersonGuardian.decode_and_verify(access_token, %{"typ" => "access"})
    person = Repo.get!(Person, id)
    render(conn, PrisonRideshareWeb.PersonView, "show.json-api", data: person)
  end

  # def create(_conn, %{"grant_type" => _}) do
  #   ## Handle unknown grant type
  #   throw "Unsupported grant_type"
  # end
end
