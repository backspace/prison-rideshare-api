defmodule Mix.Tasks.Import do
  use Mix.Task

  alias PrisonRideshare.{Institution, Person, Reimbursement, Repo, Report, Request}

  @shortdoc "Imports CSVs"

  def run([requests, reports, reimbursements | _]) do
    Mix.Task.run "app.start"

    institution_rate_overrides = %{
      "headingley" => 35,
      "stony mountain" => 35,
      "rockwood" => 35
    }

    institution_spelling_overrides = %{
      "headingly" => "headingley",
      "stony mountian" => "stony mountain"
    }

    %{request_row_to_model: request_row_to_model, person_name_to_model: person_name_to_model} = File.stream!(requests)
    |> CSV.decode
    |> Stream.with_index
    |> Enum.reduce(%{institution_name_to_model: %{}, person_name_to_model: %{}, request_row_to_model: %{}}, fn({row, i}, acc) ->
      if i > 0 do
        %{institution_name_to_model: institution_name_to_model, person_name_to_model: person_name_to_model, request_row_to_model: request_row_to_model} = acc

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

        request_attrs = %{}
        |> Map.put(:address, (if address != "", do: address, else: "MISSING"))
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

        request_model = Request.changeset(%Request{}, request_attrs)
        |> Repo.insert!

        request_row_to_model = Map.put(request_row_to_model, i + 1, request_model)

        %{institution_name_to_model: institution_name_to_model, person_name_to_model: person_name_to_model, request_row_to_model: request_row_to_model}
      else
        acc
      end
    end)

    request_models = Map.values(request_row_to_model)

    File.stream!(reports)
    |> CSV.decode
    |> Stream.with_index
    |> Enum.reduce(%{}, fn({row, i}, acc) ->
      if i > 0 do
        [_, ride_string, distance, _, food, notes, rate | _] = row

        Mix.shell.info "Importing this report:"
        Mix.shell.info row

        request = find_request_from_ride_string(request_models, ride_string)

        Report.changeset(%Report{}, %{
          distance: distance,
          rate: round(String.to_float(rate) * 100),
          food: (if food == "", do: 0, else: food),
          notes: notes,
          request_id: request.id
        })
        |> Repo.insert!

        acc
      else
        acc
      end
    end)

    File.stream!(reimbursements)
    |> CSV.decode
    |> Stream.with_index
    |> Enum.each(fn {row, i} ->
      if i > 0 do
        [name, _, amount] = row

        Mix.shell.info "Importing this reïmbursement:"
        Mix.shell.info row

        matching_name = String.trim(String.downcase(name))

        person = person_name_to_model[matching_name]

        parsed_amount = -1 * case String.contains?(amount, ".") do
          true -> round(String.to_float(amount) * 100)
          false -> String.to_integer(amount) * 100
        end

        r = Reimbursement.changeset(%Reimbursement{}, %{
          amount: parsed_amount,
          person_id: person.id
        })
        |> Repo.insert!
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

  defp find_request_from_ride_string(requests, ride_string) do
    # Example ride string: 07:45 PM on Fri, Aug 5 to Milner Ridge [X]
    [_, time_and_date_string] = Regex.run(~r/(\d\d:\d\d .M on ...\, ... \d+) to .* \[.*\]/, ride_string)

    Enum.find(requests, fn request ->
      formatted_request = PrisonRideshare.ReportView.format_request_without_institution(request)

      String.contains? time_and_date_string, formatted_request
    end)
  end
end
