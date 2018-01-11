defmodule PrisonRideshareWeb.PersonSessionController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.Person

  def create(conn, %{"grant_type" => "magic", "token" => magic_token}) do
    case PrisonRideshare.PersonGuardian.exchange_magic(magic_token) do
      {:ok, access_token, _claims} -> conn |> json(%{access_token: access_token}) # Return token to the client
      {:error, %CaseClauseError{term: {:error, {:badarg, _}}}} ->
        conn
        |> put_status(401)
        |> render(PrisonRideshareWeb.ErrorView, "401.json")
    end
  end

  def show(conn, %{"token" => access_token}) do
    {:ok, %{"sub" => "Person:" <> id}} = PrisonRideshare.PersonGuardian.decode_and_verify(access_token, %{"typ" => "access"})
    person = Repo.get!(Person, id)
    render(conn, PrisonRideshareWeb.PersonCalendarView, "show.json-api", data: person)
  end
end
