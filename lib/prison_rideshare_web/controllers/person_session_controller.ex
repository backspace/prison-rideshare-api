defmodule PrisonRideshareWeb.PersonSessionController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.Person
  alias JaSerializer.Params

  def create(conn, %{"grant_type" => "magic", "token" => magic_token}) do
    case PrisonRideshare.PersonGuardian.exchange_magic(magic_token) do
      # Return token to the client
      {:ok, access_token, _claims} ->
        conn |> json(%{access_token: access_token})

      {:error, %CaseClauseError{term: {:error, {:badarg, _}}}} ->
        conn
        |> put_status(401)
        |> render(PrisonRideshareWeb.ErrorView, "401.json")

      {:error, :token_expired} ->
        conn
        |> put_status(401)
        |> render(PrisonRideshareWeb.ErrorView, "401.json", detail: "That token is expired. Did you click an old link?")
    end
  end

  def show(conn, %{"token" => access_token}) do
    {:ok, %{"sub" => "Person:" <> id}} =
      PrisonRideshare.PersonGuardian.decode_and_verify(access_token, %{"typ" => "access"})

    person = Repo.get!(Person, id)
    render(conn, PrisonRideshareWeb.PersonCalendarView, "show.json-api", data: person)
  end

  def update(conn, %{
        "data" => data = %{"id" => _id, "type" => "people", "attributes" => _person_params}
      }) do
    ["Person Bearer " <> access_token] = get_req_header(conn, "authorization")

    {:ok, %{"sub" => "Person:" <> id}} =
      PrisonRideshare.PersonGuardian.decode_and_verify(access_token, %{"typ" => "access"})

    person = Repo.get!(Person, id)
    changeset = Person.self_changeset(person, Params.to_attributes(data))

    case PaperTrail.update(changeset, version_information(conn)) do
      {:ok, %{model: person}} ->
        render(conn, PrisonRideshareWeb.PersonCalendarView, "show.json-api", data: person)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PrisonRideshareWeb.PersonCalendarView, :errors, data: changeset)
    end
  end
end
