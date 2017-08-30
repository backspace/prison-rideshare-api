defmodule PrisonRideshare.InstitutionController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.Institution
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, _params) do
    institutions = Repo.all(Institution)
    render(conn, "index.json-api", data: institutions)
  end

  def create(conn, %{"data" => data = %{"type" => "institutions", "attributes" => _institution_params}}) do
    changeset = Institution.changeset(%Institution{}, Params.to_attributes(data))

    case PaperTrail.insert(changeset, version_information(conn)) do
      {:ok, %{model: institution}} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", institution_path(conn, :show, institution))
        |> render("show.json-api", data: institution)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    institution = Repo.get!(Institution, id)
    render(conn, "show.json-api", data: institution)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "institutions", "attributes" => _institution_params}}) do
    institution = Repo.get!(Institution, id)
    changeset = Institution.changeset(institution, Params.to_attributes(data))

    case PaperTrail.update(changeset, version_information(conn)) do
      {:ok, %{model: institution}} ->
        render(conn, "show.json-api", data: institution)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    institution = Repo.get!(Institution, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    PaperTrail.delete!(institution, version_information(conn))

    send_resp(conn, :no_content, "")
  end

end
