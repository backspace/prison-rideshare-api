defmodule PrisonRideshare.RideController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.{Institution, Person, Ride}

  def index(conn, _params) do
    rides = Ride.sorted(Ride)
    |> Repo.all
    |> Repo.preload(:institution)
    |> Repo.preload(:driver)
    |> Repo.preload(:car_owner)
    render(conn, "index.html", rides: rides)
  end

  def new(conn, _params) do
    changeset = Ride.changeset(%Ride{})
    institutions = Repo.all(Institution)
    render(conn, "new.html", institutions: institutions, people: people, changeset: changeset)
  end

  def create(conn, %{"ride" => ride_params}) do
    changeset = Ride.changeset(%Ride{}, ride_params)
    institutions = Repo.all(Institution)

    case Repo.insert(changeset) do
      {:ok, _ride} ->
        conn
        |> put_flash(:info, "Ride created successfully.")
        |> redirect(to: ride_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", institutions: institutions, people: people, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    ride = Repo.get!(Ride, id)
    |> Repo.preload(:institution)
    |> Repo.preload(:driver)
    |> Repo.preload(:car_owner)
    |> Repo.preload(:combined_with)

    render(conn, "show.html", ride: ride)
  end

  def edit(conn, %{"id" => id}) do
    ride = Repo.get!(Ride, id)
    changeset = Ride.changeset(ride)
    institutions = Repo.all(Institution)
    render(conn, "edit.html", ride: ride, institutions: institutions, people: people, changeset: changeset)
  end

  def update(conn, %{"id" => id, "ride" => ride_params}) do
    ride = Repo.get!(Ride, id)
    changeset = Ride.changeset(ride, ride_params)
    institutions = Repo.all(Institution)

    case Repo.update(changeset) do
      {:ok, ride} ->
        conn
        |> put_flash(:info, "Ride updated successfully.")
        |> redirect(to: ride_path(conn, :show, ride))
      {:error, changeset} ->
        render(conn, "edit.html", ride: ride, institutions: institutions, people: people, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    ride = Repo.get!(Ride, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(ride)

    conn
    |> put_flash(:info, "Ride deleted successfully.")
    |> redirect(to: ride_path(conn, :index))
  end

  defp people do
    Person.sorted(Person) |> Repo.all
  end
end
