defmodule PrisonRideshareWeb.RideController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.{Commitment, Ride}
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
    now = Timex.now()

    rides =
      Repo.all(
        from(
          r in Ride,
          where:
            r.enabled and is_nil(r.combined_with_ride_id) and r.start < ^now and not r.complete and
              not is_nil(r.driver_id),
          order_by: [desc: r.start],
          preload: [:institution, :driver]
        )
      )

    conn
    |> put_view(PrisonRideshareWeb.UnauthRideView)
    |> render("index.json-api", data: rides)
  end

  def overlaps(conn, _) do
    slot_intervals =
      Repo.all(Commitment)
      |> Repo.preload([:person, slot: [commitments: [:person, :slot]]])
      |> Enum.map(fn commitment -> commitment.slot end)
      |> Enum.uniq()
      |> Enum.map(fn slot ->
        %{slot: slot, interval: Timex.Interval.new(from: slot.start, until: slot.end)}
      end)

    now = NaiveDateTime.utc_now()

    rides =
      Repo.all(
        from(
          r in Ride,
          where:
            r.enabled and is_nil(r.combined_with_ride_id) and r.start >= ^now and
              is_nil(r.driver_id)
        )
      )
      |> preload
      |> Enum.reduce([], fn ride, rides ->
        ride_interval = Timex.Interval.new(from: ride.start, until: ride.end)

        if ride_interval != {:error, :invalid_until} do
          commitments =
            Enum.reduce(slot_intervals, [], fn slot_interval, commitments ->
              commitments =
                commitments ++
                  case Timex.Interval.overlaps?(slot_interval[:interval], ride_interval) do
                    true ->
                      slot_interval[:slot].commitments
                      |> Enum.reject(fn commitment ->
                        Enum.member?(ride.ignored_commitment_ids, commitment.id)
                      end)
                      |> Enum.map(fn commitment ->
                        Map.put(commitment, :slot, slot_interval[:slot])
                      end)

                    _ ->
                      []
                  end

              commitments
            end)

          ride = Map.put(ride, :commitments, commitments)

          rides =
            rides ++
              case Enum.empty?(commitments) do
                true -> []
                false -> [ride]
              end

          rides
        else
          rides
        end
      end)

    conn
    |> put_view(PrisonRideshareWeb.OverlapRideView)
    |> render("index.json-api", data: Enum.sort_by(rides, fn ride -> ride.start end))
  end

  def ignore_commitment(conn, %{"id" => ride_id, "commitment_id" => commitment_id}) do
    ride =
      Repo.get!(Ride, ride_id)
      |> preload

    changeset = Ride.ignore_commitment_changeset(ride, commitment_id)
    PaperTrail.update(changeset, version_information(conn))

    render(conn, "show.json-api", data: ride)
  end

  def calendar(conn, _) do
    rides =
      Repo.all(
        from(
          r in Ride,
          where:
            r.enabled and is_nil(r.combined_with_ride_id) and is_nil(r.distance) and
              not (r.car_expenses > 0) and is_nil(r.driver_id),
          preload: [:institution, :driver, :children]
        )
      )

    events =
      Enum.map(Enum.sort_by(rides, fn ride -> ride.start end), fn ride ->
        request_count = 1 + length(ride.children)

        passenger_count =
          Enum.map([ride] ++ ride.children, fn ride -> ride.passengers end)
          |> Enum.sum()

        institution_name = ride.institution.name

        summary =
          "#{institution_name}: #{request_count} request#{
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
            DateTime.from_naive!(
              NaiveDateTime.from_erl!(Ecto.DateTime.to_erl(ride.start)),
              "Etc/UTC"
            ),
          dtend:
            DateTime.from_naive!(
              NaiveDateTime.from_erl!(Ecto.DateTime.to_erl(ride.end)),
              "Etc/UTC"
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

        if Ecto.Changeset.get_change(changeset, :complete) do
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
