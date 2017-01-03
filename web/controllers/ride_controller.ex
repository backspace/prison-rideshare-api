defmodule PrisonRideshare.RideController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.Ride
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, _params) do
    rides = Repo.all(Ride)
    |> preload
    render(conn, "index.json-api", data: rides)
  end

  def create(conn, %{"data" => data = %{"type" => "ride", "attributes" => _ride_params}}) do
    changeset = Ride.changeset(%Ride{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, ride} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ride_path(conn, :show, ride))
        |> render("show.json-api", data: ride |> preload)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    ride = Repo.get!(Ride, id)
    |> preload
    render(conn, "show.json-api", data: ride)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "ride", "attributes" => _ride_params}}) do
    ride = Repo.get!(Ride, id)
    |> preload
    changeset = Ride.changeset(ride, Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, ride} ->
        render(conn, "show.json-api", data: ride)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    ride = Repo.get!(Ride, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(ride)

    send_resp(conn, :no_content, "")
  end

  defp preload(model) do
    model
    |> Repo.preload([:institution, :driver, :car_owner])
  end
end
