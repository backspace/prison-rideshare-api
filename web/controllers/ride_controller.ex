defmodule PrisonRideshare.RideController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.Ride
  alias JaSerializer.Params

  import Ecto.Query

  plug :scrub_params, "data" when action in [:create, :update]
  plug PrisonRideshare.Plugs.Admin when not action in [:index, :update]

  def index(%{private: %{guardian_default_resource: %{admin: true}}} = conn, _params) do
    rides = Repo.all(Ride)
    |> preload

    conn
    |> render("index.json-api", data: rides)
  end

  def index(conn, _) do
    rides = Repo.all from r in Ride, where: r.enabled and is_nil(r.distance) and is_nil(r.combined_with_ride_id), preload: [:institution]

    conn
    |> put_view(PrisonRideshare.UnauthRideView)
    |> render("index.json-api", data: rides)
  end

  def create(conn, %{"data" => data = %{"type" => "rides", "attributes" => _ride_params}}) do
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

  def update(conn, %{"id" => id, "data" => data = %{"type" => "rides", "attributes" => _ride_params}}) do
    ride = Repo.get!(Ride, id)
    |> preload

    {changeset, conn} = case conn do
      %{private: %{guardian_default_resource: %{admin: true}}} -> {Ride.changeset(ride, Params.to_attributes(data)), conn}
      _ -> {Ride.report_changeset(ride, Params.to_attributes(data)), put_view(conn, PrisonRideshare.UnauthRideView)}
    end

    case Repo.update(changeset) do
      {:ok, ride} ->
        ride = preload(ride)
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
    |> Repo.preload([:institution, :driver, :car_owner, :children, [reimbursements: :person]], force: true)
  end
end
