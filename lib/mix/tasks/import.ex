defmodule Mix.Tasks.Import do
  use Mix.Task

  alias PrisonRideshare.{Institution, Person, Repo, Report, Request}

  @shortdoc "Imports CSVs"

  def run([requests, reports | _]) do
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

        matching_driver = String.trim(String.downcase(driver))

        {person_name_to_model, driver_model} = maybe_add_person(person_name_to_model, matching_driver, driver)

        matching_car_owner = String.trim(String.downcase(car_owner))

        {person_name_to_model, car_owner_model} = maybe_add_person(person_name_to_model, matching_car_owner, car_owner)

        request_attrs = Map.put(valid_attrs, :address, (if address != "", do: address, else: "MISSING"))
        |> Map.put(:date, Timex.parse!(date, "{M}/{D}/{YYYY}"))
        |> Map.put(:start, parse_time(start_time))
        |> Map.put(:end, parse_time(end_time, start_time))
        |> Map.put(:name, name)
        |> Map.put(:contact, contact)
        |> Map.put(:passengers, passengers)
        |> Map.put(:notes, notes)
        |> Map.put(:institution_id, institution_model.id)

        request_attrs = maybe_put_id(request_attrs, :driver_id, driver_model)
        request_attrs = maybe_put_id(request_attrs, :car_owner_id, car_owner_model)

        r = Request.changeset(%Request{}, request_attrs)
        |> Repo.insert!

        %{institution_name_to_model: institution_name_to_model, person_name_to_model: person_name_to_model}
      else
        acc
      end
    end)

    File.stream!(reports)
    |> CSV.decode
    |> Stream.with_index
    |> Enum.reduce(%{}, fn({row, i}, acc) ->
      if i > 0 do
        [_, _, distance, _, expenses, notes | _] = row

        Mix.shell.info "Importing this report:"
        Mix.shell.info row

        Report.changeset(%Report{}, %{distance: distance, expenses: expenses, notes: notes})
        |> Repo.insert!

        acc
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

  defp maybe_add_person(person_name_to_model, _, "") do
    {person_name_to_model, nil}
  end

  defp maybe_add_person(person_name_to_model, matching_name, name) do
    new_map = Map.put_new_lazy(person_name_to_model, matching_name, fn ->
      Person.changeset(%Person{}, %{name: name})
      |> Repo.insert!
    end)

    {new_map, new_map[matching_name]}
  end

  defp maybe_put_id(map, _, nil) do
    map
  end

  defp maybe_put_id(map, attr, model) do
    Map.put(map, attr, model.id)
  end
end
