defmodule PrisonRideshare.InstitutionController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.Institution

  def index(conn, _params) do
    institutions = Repo.all(Institution)
    render(conn, "index.html", institutions: institutions)
  end

  def new(conn, _params) do
    changeset = Institution.changeset(%Institution{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"institution" => institution_params}) do
    changeset = Institution.changeset(%Institution{}, institution_params)

    case Repo.insert(changeset) do
      {:ok, _institution} ->
        conn
        |> put_flash(:info, "Institution created successfully.")
        |> redirect(to: institution_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    institution = Repo.get!(Institution, id)
    render(conn, "show.html", institution: institution)
  end

  def edit(conn, %{"id" => id}) do
    institution = Repo.get!(Institution, id)
    changeset = Institution.changeset(institution)
    render(conn, "edit.html", institution: institution, changeset: changeset)
  end

  def update(conn, %{"id" => id, "institution" => institution_params}) do
    institution = Repo.get!(Institution, id)
    changeset = Institution.changeset(institution, institution_params)

    case Repo.update(changeset) do
      {:ok, institution} ->
        conn
        |> put_flash(:info, "Institution updated successfully.")
        |> redirect(to: institution_path(conn, :show, institution))
      {:error, changeset} ->
        render(conn, "edit.html", institution: institution, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    institution = Repo.get!(Institution, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(institution)

    conn
    |> put_flash(:info, "Institution deleted successfully.")
    |> redirect(to: institution_path(conn, :index))
  end
end
