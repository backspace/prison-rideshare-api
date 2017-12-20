defmodule PrisonRideshareWeb.CommitmentController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.{Commitment, Slot}
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create]

  def create(conn, %{"data" => data = %{"type" => "commitments"}}) do
    person = PrisonRideshare.PersonGuardian.Plug.current_resource(conn)

    cond do
      person.id == data["relationships"]["person"]["data"]["id"] ->
        slot = Repo.get!(Slot, data["relationships"]["slot"]["data"]["id"])
        |> Repo.preload(:commitments)

        if slot.count == 0 || length(slot.commitments) + 1 < slot.count do
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
        else
          conn
          |> put_status(:unprocessable_entity)
          |> render(:errors, data:
            [%{
              :detail => "Slot has its maximum number of commitments",
              :source => %{"pointer" => "/data/relationships/slot"},
              :title => "is full"
            }]
          )
        end
      true ->
        conn
        |> put_status(:unauthorized)
        |> render(PrisonRideshareWeb.ErrorView, "401.json")
    end
  end

  def delete(conn, %{"id" => id}) do
    commitment = Repo.get!(Commitment, id)
    person = PrisonRideshare.PersonGuardian.Plug.current_resource(conn)

    cond do
      person.id == commitment.person_id ->
        PaperTrail.delete!(commitment, version_information(conn))
        send_resp(conn, :no_content, "")
      true ->
        conn
        |> put_status(:unauthorized)
        |> render(PrisonRideshareWeb.ErrorView, "401.json")
    end    
  end
end
