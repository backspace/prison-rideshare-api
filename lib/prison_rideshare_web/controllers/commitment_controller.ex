defmodule PrisonRideshareWeb.CommitmentController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.{Commitment, Slot}
  alias JaSerializer.Params

  plug(:scrub_params, "data" when action in [:create])

  def create(%{private: %{guardian_default_resource: %{admin: true}}} = conn, %{
        "data" => data = %{"type" => "commitments"}
      }) do
    changeset = Commitment.changeset(%Commitment{}, Params.to_attributes(data))

    case PaperTrail.insert(changeset, version_information(conn)) do
      {:ok, %{model: commitment}} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", commitment_path(conn, :show, commitment))
        |> render("show.json-api", data: commitment |> Repo.preload([:person, :slot]))
    end
  end

  def create(conn, %{"data" => data = %{"type" => "commitments"}}) do
    person = PrisonRideshare.PersonGuardian.Plug.current_resource(conn)

    slot =
      Repo.get!(Slot, data["relationships"]["slot"]["data"]["id"])
      |> Repo.preload(:commitments)

    cond do
      !person ->
        conn
        |> put_status(:unauthorized)
        |> render(PrisonRideshareWeb.ErrorView, "401.json")

      person.id != data["relationships"]["person"]["data"]["id"] ->
        conn
        |> put_status(:unauthorized)
        |> render(PrisonRideshareWeb.ErrorView, "401.json")

      slot.count != 0 && length(slot.commitments) + 1 > slot.count ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(
          :errors,
          data: [
            %{
              :detail => "Slot has its maximum number of commitments",
              :source => %{"pointer" => "/data/relationships/slot"},
              :title => "is full"
            }
          ]
        )

      Enum.any?(slot.commitments, fn commitment -> commitment.person_id == person.id end) ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(
          :errors,
          data: [
            %{
              :detail => "Person is already committed to this slot",
              :source => %{"pointer" => "/data/relationships/slot"},
              :title => "is already committed-to"
            }
          ]
        )

      Timex.before?(slot.start, Timex.now()) ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(
          :errors,
          data: [
            %{
              :detail => "Cannot commit to a past slot",
              :source => %{"pointer" => "/data/relationships/slot"},
              :title => "is in the past"
            }
          ]
        )

      true ->
        changeset = Commitment.changeset(%Commitment{}, Params.to_attributes(data))

        case PaperTrail.insert(changeset, version_information(conn)) do
          {:ok, %{model: commitment}} ->
            conn
            |> put_status(:created)
            |> put_resp_header("location", commitment_path(conn, :show, commitment))
            |> render("show.json-api", data: commitment |> Repo.preload([:person, :slot]))
        end
    end
  end

  def delete(%{private: %{guardian_default_resource: %{admin: true}}} = conn, %{"id" => id}) do
    commitment =
      Repo.get!(Commitment, id)
      |> Repo.preload(:slot)

    PaperTrail.delete!(commitment, version_information(conn))
    send_resp(conn, :no_content, "")
  end

  def delete(conn, %{"id" => id}) do
    commitment =
      Repo.get!(Commitment, id)
      |> Repo.preload(:slot)

    person = PrisonRideshare.PersonGuardian.Plug.current_resource(conn)

    cond do
      Timex.before?(commitment.slot.start, Timex.now()) ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(
          :errors,
          data: [
            %{
              :detail => "Cannot delete a past commitment",
              :source => %{"pointer" => "/data/relationships/slot"},
              :title => "is in the past"
            }
          ]
        )

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
