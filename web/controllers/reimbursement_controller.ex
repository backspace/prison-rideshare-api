defmodule PrisonRideshare.ReimbursementController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.Reimbursement
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, _params) do
    reimbursements = Repo.all(Reimbursement)
    |> Repo.preload([:person, :ride])
    render(conn, "index.json-api", data: reimbursements)
  end

  def create(conn, %{"data" => data = %{"type" => "reimbursements", "attributes" => _reimbursement_params}}) do
    changeset = Reimbursement.changeset(%Reimbursement{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, reimbursement} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", reimbursement_path(conn, :show, reimbursement))
        |> render("show.json-api", data: reimbursement |> Repo.preload([:person, :ride]))
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    reimbursement = Repo.get!(Reimbursement, id)
    |> Repo.preload([:person, :ride])
    render(conn, "show.json-api", data: reimbursement)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "reimbursements", "attributes" => _reimbursement_params}}) do
    reimbursement = Repo.get!(Reimbursement, id)
    |> Repo.preload([:person, :ride])
    changeset = Reimbursement.changeset(reimbursement, Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, reimbursement} ->
        render(conn, "show.json-api", data: reimbursement)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    reimbursement = Repo.get!(Reimbursement, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(reimbursement)

    send_resp(conn, :no_content, "")
  end

end
