defmodule Mix.Tasks.Import do
  use Mix.Task

  alias PrisonRideshare.{Institution, Person, Repo, Request}

  @shortdoc "Imports CSVs"

  def run([requests | _]) do
    Mix.Task.run "app.start"

    valid_attrs = %{name: "some content", address: "some content", contact: "some content", date: %{day: 17, month: 4, year: 2010}, end: %{hour: 14, min: 0, sec: 0}, notes: "some content", passengers: 42, start: %{hour: 14, min: 0, sec: 0}}

    institution_rate_overrides = %{
      "headingley" => 35,
      "stony mountain" => 35,
      "rockwood" => 35
    }

    institution_spelling_overrides = %{
      "headingly" => "headingley",
      "stony mountian" => "stony mountain"
    }

    File.stream!(requests)
    |> CSV.decode
    |> Stream.with_index
    |> Enum.reduce(%{institution_name_to_model: %{}, person_name_to_model: %{}}, fn({row, i}, acc) ->
      if i > 0 do
        %{institution_name_to_model: institution_name_to_model, person_name_to_model: person_name_to_model} = acc

        [_, date, institution, start_time, end_time, address, name, contact, passengers, _, _, driver, car_owner, notes | _] = row

        Mix.shell.info "Importing this request:"
        Mix.shell.info row

        matching_institution = String.downcase(institution)
        matching_institution = Map.get(institution_spelling_overrides, matching_institution, matching_institution)

        institution_name_to_model = Map.put_new_lazy(institution_name_to_model, matching_institution, fn ->
          rate = Map.get(institution_rate_overrides, matching_institution, 25)

          Institution.changeset(%Institution{}, %{name: institution, rate: rate})
          |> Repo.insert!
        end)

        institution_model = Map.get(institution_name_to_model, matching_institution)

        person_name_to_model = Map.put_new_lazy(person_name_to_model, driver, fn ->
          Person.changeset(%Person{}, %{name: driver})
          |> Repo.insert!
        end)

        driver_model = person_name_to_model[driver]

        person_name_to_model = Map.put_new_lazy(person_name_to_model, car_owner, fn ->
          Person.changeset(%Person{}, %{name: car_owner})
          |> Repo.insert!
        end)

        car_owner_model = person_name_to_model[car_owner]

        request_attrs = Map.put(valid_attrs, :address, (if address != "", do: address, else: "MISSING"))
        |> Map.put(:date, Timex.parse!(date, "{M}/{D}/{YYYY}"))
        |> Map.put(:start, parse_time(start_time))
        |> Map.put(:end, parse_time(end_time, start_time))
        |> Map.put(:name, name)
        |> Map.put(:contact, contact)
        |> Map.put(:passengers, passengers)
        |> Map.put(:notes, notes)
        |> Map.put(:institution_id, institution_model.id)
        |> Map.put(:driver_id, driver_model.id)
        |> Map.put(:car_owner_id, car_owner_model.id)

        r = Request.changeset(%Request{}, request_attrs)
        |> Repo.insert!

        %{institution_name_to_model: institution_name_to_model, person_name_to_model: person_name_to_model}
      else
        acc
      end
    end)
  end

  defp parse_time(time, fallback \\ nil)

  defp parse_time("", fallback) do
    parse_time(fallback)
  end

  defp parse_time(time, _) do
    case Timex.parse(time, "{h12}:{m}:{s} {AM}") do
      {:ok, parsed} -> parsed
      {:error, _} -> Timex.parse!(time, "{h12}:{m} {AM}")
    end
  end
end
