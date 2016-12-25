defmodule PrisonRideshare.ReimbursementController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.Reimbursement

  def index(conn, _params) do
    reimbursements = Repo.all(Reimbursement)
    render(conn, "index.html", reimbursements: reimbursements)
  end

  def new(conn, _params) do
    changeset = Reimbursement.changeset(%Reimbursement{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"reimbursement" => reimbursement_params}) do
    changeset = Reimbursement.changeset(%Reimbursement{}, reimbursement_params)

    case Repo.insert(changeset) do
      {:ok, _reimbursement} ->
        conn
        |> put_flash(:info, "Reimbursement created successfully.")
        |> redirect(to: reimbursement_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    reimbursement = Repo.get!(Reimbursement, id)
    render(conn, "show.html", reimbursement: reimbursement)
  end

  def edit(conn, %{"id" => id}) do
    reimbursement = Repo.get!(Reimbursement, id)
    changeset = Reimbursement.changeset(reimbursement)
    render(conn, "edit.html", reimbursement: reimbursement, changeset: changeset)
  end

  def update(conn, %{"id" => id, "reimbursement" => reimbursement_params}) do
    reimbursement = Repo.get!(Reimbursement, id)
    changeset = Reimbursement.changeset(reimbursement, reimbursement_params)

    case Repo.update(changeset) do
      {:ok, reimbursement} ->
        conn
        |> put_flash(:info, "Reimbursement updated successfully.")
        |> redirect(to: reimbursement_path(conn, :show, reimbursement))
      {:error, changeset} ->
        render(conn, "edit.html", reimbursement: reimbursement, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    reimbursement = Repo.get!(Reimbursement, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(reimbursement)

    conn
    |> put_flash(:info, "Reimbursement deleted successfully.")
    |> redirect(to: reimbursement_path(conn, :index))
  end
end
