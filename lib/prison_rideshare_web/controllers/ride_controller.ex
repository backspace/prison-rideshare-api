defmodule PrisonRideshareWeb.RideController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.Ride
  alias JaSerializer.Params

  import Ecto.Query

  plug(:scrub_params, "data" when action in [:create, :update])
  plug(PrisonRideshareWeb.Plugs.Admin when action not in [:index, :update, :calendar])

  def index(%{private: %{guardian_default_resource: %{admin: true}}} = conn, params) do
    rides =
      case params do
        %{"filter" => %{"name" => name}} ->
          Repo.all(from(r in Ride, where: ilike(r.name, ^"#{name}%"), order_by: [desc: r.start]))

        _ ->
          Repo.all(Ride)
      end

    rides = preload(rides)

    conn
    |> render("index.json-api", data: rides)
  end

  def index(conn, _) do
    rides =
      Repo.all(
        from(
          r in Ride,
          where:
            r.enabled and is_nil(r.distance) and is_nil(r.combined_with_ride_id) and
              not is_nil(r.driver_id),
          preload: [:institution, :driver]
        )
      )

    conn
    |> put_view(PrisonRideshareWeb.UnauthRideView)
    |> render("index.json-api", data: rides)
  end

  def calendar(conn, _) do
    rides =
      Repo.all(
        from(
          r in Ride,
          where:
            r.enabled and is_nil(r.distance) and is_nil(r.combined_with_ride_id) and
              is_nil(r.driver_id),
          preload: [:institution, :driver, :children]
        )
      )

    events =
      Enum.map(Enum.sort_by(rides, fn ride -> ride.start end), fn ride ->
        request_count = 1 + length(ride.children)

        passenger_count =
          Enum.map([ride] ++ ride.children, fn ride -> ride.passengers end)
          |> Enum.sum()

        summary =
          "#{ride.institution.name}: #{request_count} request#{
            if request_count > 1 do
              "s"
            end
          }#{
            if passenger_count > 1 do
              ", #{passenger_count} passengers"
            end
          }"

        %ICalendar.Event{
          summary: summary,
          description: "Please email barnone.coordinator@gmail.com to get assigned to this ride.",
          dtstart:
            Timex.Timezone.convert(
              Timex.Timezone.resolve("UTC", Ecto.DateTime.to_erl(ride.start), :utc),
              "UTC"
            ),
          dtend:
            Timex.Timezone.convert(
              Timex.Timezone.resolve("UTC", Ecto.DateTime.to_erl(ride.end), :utc),
              "UTC"
            )
        }
      end)

    ics = %ICalendar{events: events} |> ICalendar.to_ics()

    conn
    |> put_resp_content_type("text/calendar")
    |> text(ics)
  end

  def create(conn, %{"data" => data = %{"type" => "rides", "attributes" => _ride_params}}) do
    changeset = Ride.changeset(%Ride{}, Params.to_attributes(data))

    case PaperTrail.insert(changeset, version_information(conn)) do
      {:ok, %{model: ride}} ->
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
    ride =
      Repo.get!(Ride, id)
      |> preload

    render(conn, "show.json-api", data: ride)
  end

  def update(conn, %{
        "id" => id,
        "data" => data = %{"type" => "rides", "attributes" => _ride_params}
      }) do
    ride =
      Repo.get!(Ride, id)
      |> preload

    fixed_params = rename_combined_with(Params.to_attributes(data))

    {changeset, conn} =
      case conn do
        %{private: %{guardian_default_resource: %{admin: true}}} ->
          {Ride.changeset(ride, fixed_params), conn}

        _ ->
          {Ride.report_changeset(ride, fixed_params),
           put_view(conn, PrisonRideshareWeb.UnauthRideView)}
      end

    case PaperTrail.update(changeset, version_information(conn)) do
      {:ok, %{model: ride}} ->
        ride = preload(ride)

        if Ecto.Changeset.get_change(changeset, :distance) do
          PrisonRideshare.Email.report(ride)
          |> PrisonRideshare.Mailer.deliver_later()
        end

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
    PaperTrail.delete!(ride, version_information(conn))

    send_resp(conn, :no_content, "")
  end

  defp preload(model) do
    model
    |> Repo.preload(
      [:institution, :driver, :car_owner, :children, [reimbursements: [:person, :ride]]],
      force: true
    )
  end

  # FIXME figure out where this magic is broken
  defp rename_combined_with(params) do
    Map.put(params, "combined_with_ride_id", params["combined_with_id"])
  end
end
