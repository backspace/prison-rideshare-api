defmodule PrisonRideshareWeb.PersonController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.Person
  alias JaSerializer.Params
  require Logger

  plug(:scrub_params, "data" when action in [:create, :update])

  def index(conn, _params) do
    people = Repo.all(Person)
    render(conn, "index.json-api", data: people)
  end

  def create(conn, %{"data" => data = %{"type" => "people", "attributes" => _person_params}}) do
    changeset = Person.changeset(%Person{}, Params.to_attributes(data))

    case PaperTrail.insert(changeset, version_information(conn)) do
      {:ok, %{model: person}} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", person_path(conn, :show, person))
        |> render("show.json-api", data: person)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def email_calendar_link(conn, %{"id" => id, "month" => month}) do
    person = Repo.get!(Person, id)

    PrisonRideshare.Email.calendar_link(person, month)
    |> PrisonRideshare.Mailer.deliver_later()

    send_resp(conn, :no_content, "")
  end

  def show(conn, %{"id" => id}) do
    person = Repo.get!(Person, id)
    render(conn, "show.json-api", data: person)
  end

  def calendar(conn, %{"id" => id}) do
    person =
      Repo.get!(Person, id)
      |> Repo.preload([drivings: [:institution, :children], commitments: [:slot]], force: true)

    events =
      Enum.map(Enum.sort_by(person.drivings, fn ride -> ride.start end), fn ride ->
        %ICalendar.Event{
          summary:
            "#{
              unless ride.enabled do
                "CANCELLED "
              end
            }Visit to #{ride.institution.name}",
          description:
            Enum.join(
              Enum.map([ride] ++ ride.children, fn ride ->
                """
                #{ride.name}
                #{ride.address}
                #{ride.contact}
                """
              end),
              "\n\n"
            ),
          # FIXME really?
          dtstart:
            Timex.Timezone.convert(
              Timex.Timezone.resolve("UTC", Ecto.DateTime.to_erl(ride.start), :utc),
              "UTC"
            ),
          dtend:
            Timex.Timezone.convert(
              Timex.Timezone.resolve("UTC", Ecto.DateTime.to_erl(ride.end), :utc),
              "UTC"
            ),
          location:
            Enum.join(
              [ride.address] ++ Enum.map(ride.children, fn child -> child.address end),
              ", "
            )
        }
      end) ++
        Enum.map(
          Enum.sort_by(person.commitments, fn commitment -> commitment.slot.start end),
          fn commitment ->
            slot = commitment.slot

            %ICalendar.Event{
              summary: "Prison rideshare slot commitment",
              dtstart:
                Timex.Timezone.convert(
                  Timex.Timezone.resolve("UTC", NaiveDateTime.to_erl(slot.start), :utc),
                  "UTC"
                ),
              dtend:
                Timex.Timezone.convert(
                  Timex.Timezone.resolve("UTC", NaiveDateTime.to_erl(slot.end), :utc),
                  "UTC"
                )
            }
          end
        )

    ics = %ICalendar{events: events} |> ICalendar.to_ics()

    conn
    |> put_resp_content_type("text/calendar")
    |> text(ics)
  end

  def update(conn, %{
        "id" => id,
        "data" => data = %{"type" => "people", "attributes" => _person_params}
      }) do
    person = Repo.get!(Person, id)
    changeset = Person.changeset(person, Params.to_attributes(data))

    case PaperTrail.update(changeset, version_information(conn)) do
      {:ok, %{model: person}} ->
        render(conn, "show.json-api", data: person)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    person = Repo.get!(Person, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    PaperTrail.delete!(person, version_information(conn))

    send_resp(conn, :no_content, "")
  end
end
