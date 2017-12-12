defmodule PrisonRideshareWeb.CommitmentController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.{Commitment}
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create]

  def create(conn, %{"data" => data = %{"type" => "commitments", "attributes" => _reimbursement_params}}) do
    changeset = Commitment.changeset(%Commitment{}, Params.to_attributes(data))

    case PaperTrail.insert(changeset, version_information(conn)) do
      {:ok, %{model: commitment}} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", commitment_path(conn, :show, commitment))
        |> render("show.json-api", data: commitment |> Repo.preload([:person, :slot]))
      # {:error, changeset} ->
      #   conn
      #   |> put_status(:unprocessable_entity)
      #   |> render(:errors, data: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    commitment = Repo.get!(Commitment, id)
    PaperTrail.delete!(commitment, version_information(conn))
    send_resp(conn, :no_content, "")
  end
end
