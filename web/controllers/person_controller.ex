defmodule PrisonRideshare.PersonController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.Person
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, _params) do
    people = Repo.all(Person)
    render(conn, "index.json-api", data: people)
  end

  def create(conn, %{"data" => data = %{"type" => "people", "attributes" => _person_params}}) do
    changeset = Person.changeset(%Person{}, Params.to_attributes(data))

    case PaperTrail.insert(changeset, version_information(conn)) do
      {:ok, %{model: person}} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", person_path(conn, :show, person))
        |> render("show.json-api", data: person)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    person = Repo.get!(Person, id)
    render(conn, "show.json-api", data: person)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "people", "attributes" => _person_params}}) do
    person = Repo.get!(Person, id)
    changeset = Person.changeset(person, Params.to_attributes(data))

    case PaperTrail.update(changeset, version_information(conn)) do
      {:ok, %{model: person}} ->
        render(conn, "show.json-api", data: person)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    person = Repo.get!(Person, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    PaperTrail.delete!(person, version_information(conn))

    send_resp(conn, :no_content, "")
  end

end
