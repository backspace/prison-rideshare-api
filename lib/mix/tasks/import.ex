defmodule Mix.Tasks.Import do
  use Mix.Task

  alias PrisonRideshare.{Institution, Person, Reimbursement, Repo, Ride}

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

    %{
      request_row_number_to_model: request_row_number_to_model,
      person_name_to_model: person_name_to_model,
      combined_requests: combined_requests
    } = File.stream!(requests)
    |> CSV.decode
    |> Stream.with_index
    |> Enum.reduce(%{
      institution_name_to_model: %{},
      person_name_to_model: %{},
      request_row_number_to_model: %{},
      combined_requests: []
    }, fn({row, i}, acc) ->
      if i > 0 do
        %{institution_name_to_model: institution_name_to_model, person_name_to_model: person_name_to_model, request_row_number_to_model: request_row_number_to_model, combined_requests: combined_requests} = acc

        [_, date, institution, start_time, end_time, address, name, contact, passengers, _, combined, driver, car_owner, notes | _] = row

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
        |> Map.put(:start, parse_date_and_time(date, start_time))
        |> Map.put(:end, parse_date_and_time(date, end_time, start_time))
        |> Map.put(:name, name)
        |> Map.put(:contact, contact)
        |> Map.put(:passengers, passengers)
        |> Map.put(:request_notes, notes)
        |> Map.put(:institution_id, institution_model.id)

        cancellation_reason = determine_cancellation_reason(notes)

        request_attrs = case cancellation_reason do
          false -> request_attrs |> Map.put(:enabled, true)
          reason -> request_attrs |> Map.put(:enabled, false) |> Map.put(:cancellation_reason, reason)
        end

        request_attrs = maybe_put_id(request_attrs, :driver_id, driver_model)
        request_attrs = maybe_put_id(request_attrs, :car_owner_id, car_owner_model)

        request_model = Ride.changeset(%Ride{}, request_attrs)
        |> Repo.insert!

        request_row_number_to_model = Map.put(request_row_number_to_model, i + 1, request_model)

        combined_requests = case combined do
          "" -> combined_requests
          _ -> combined_requests ++ [request_model]
        end

        %{
          institution_name_to_model: institution_name_to_model,
          person_name_to_model: person_name_to_model,
          request_row_number_to_model: request_row_number_to_model,
          combined_requests: combined_requests
        }
      else
        acc
      end
    end)

    request_models = Map.values(request_row_number_to_model)

    uncombined_requests = request_models -- combined_requests

    combine_requests(combined_requests, uncombined_requests)

    File.stream!(reports)
    |> CSV.decode
    |> Stream.with_index
    |> Enum.reduce(%{}, fn({row, i}, acc) ->
      if i > 0 do
        [_, ride_string, distance, _, food, notes, rate, car_expenses, _, _, driver, car_owner | _] = row

        Mix.shell.info "Importing this report:"
        Mix.shell.info row

        request = find_request_from_ride_string_and_names(uncombined_requests, ride_string, driver, car_owner)

        Ride.changeset(request, %{
          distance: distance,
          rate: round(String.to_float(rate) * 100),
          food_expenses: (if food == "", do: 0, else: food),
          car_expenses: (if car_expenses == "", do: 0, else: car_expenses),
          report_notes: notes,
          request_id: request.id
        })
        |> Repo.update!

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

        Reimbursement.changeset(%Reimbursement{}, %{
          amount: parsed_amount,
          person_id: person.id
        })
        |> Repo.insert!
      end
    end)
  end

  defp parse_date_and_time(date, time, fallback \\ nil)

  defp parse_date_and_time(date, "", fallback), do: parse_date_and_time(date, fallback)

  defp parse_date_and_time(date, time, _) do
    full_string = "#{date} #{time}"
    case Timex.parse(full_string, "{M}/{D}/{YYYY} {h12}:{m}:{s} {AM}") do
      {:ok, parsed} -> parsed
      {:error, _} -> Timex.parse!(full_string, "{M}/{D}/{YYYY} {h12}:{m} {AM}")
    end
  end

  defp maybe_add_person(person_name_to_model, _, "") do
    {person_name_to_model, nil}
  end

  defp maybe_add_person(person_name_to_model, matching_name, name) do
    new_map = Map.put_new_lazy(person_name_to_model, matching_name, fn ->
      Person.changeset(%Person{}, %{name: capitalised_name(name)})
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

  defp capitalised_name(name) do
    String.split(name)
    |> Enum.map(fn piece ->
      {first, rest} = String.split_at(piece, 1)
      String.upcase(first) <> rest
    end)
    |> Enum.join(" ")
  end

  defp find_request_from_ride_string_and_names(requests, ride_string, driver, car_owner) do
    # Example ride string: 07:45 PM on Fri, Aug 5 to Milner Ridge [X]
    [_, time_and_date_string] = Regex.run(~r/(\d\d:\d\d .M on ...\, ... \d+) to .* \[.*\]/, ride_string)

    Enum.find(requests, fn request ->
      request = Repo.get!(Ride, request.id)
      |> Repo.preload(:institution)
      |> Repo.preload(:driver)
      |> Repo.preload(:car_owner)

      formatted_request = format_request_without_institution(request)

      # This is a mess but the original data has integrity problems.
      case {request.driver, request.car_owner} do
        {nil, _} -> false
        {_, nil} -> false
        {rdriver, rowner} ->
          String.contains?(time_and_date_string, formatted_request) &&
          String.jaro_distance(driver, rdriver.name) > 0.8 &&
          String.jaro_distance(car_owner, rowner.name) > 0.8
      end
    end)
  end

  defp combine_requests(combined_requests, uncombined_requests) do
    Enum.each(combined_requests, fn combined ->
      match = Enum.find(uncombined_requests, fn request ->
        request.driver_id == combined.driver_id &&
        request.car_owner_id == combined.car_owner_id &&
        request.start == combined.start
      end)

      Ride.changeset(combined, %{combined_with_ride_id: match.id})
      |> Repo.update
    end)
  end

  defp determine_cancellation_reason(request_notes) do
    request_notes = String.downcase(request_notes)

    cond do
      String.contains?(request_notes, "lockdown") -> "lockdown"
      String.contains?(request_notes, "by rider") || String.contains?(request_notes, "my rider") || String.contains?(request_notes, "other ride") -> "visitor"
      String.contains?(request_notes, "no car") -> "no car"
      String.contains?(request_notes, "no driver") || String.contains?(request_notes, "no ride") -> "no driver"
      String.contains?(request_notes, "weather") -> "weather"
      String.contains?(request_notes, "transfer") -> "transfer"
      String.contains?(request_notes, "wrong") -> "error"
      String.contains?(request_notes, "mia") -> "visitor missing"
      String.contains?(request_notes, "no show") -> "driver missing"
      true -> false
    end
  end

  # FIXME these are taken from ReportView which is now dead
  def format_request_without_institution(request) do
    Timex.format!(Ecto.DateTime.to_erl(request.start), "{h12}:{m} {AM} on {WDshort}, {Mshort} {D}")
  end

  def format_request(request) do
    "#{format_request_without_institution(request)} to #{institution_name(request.institution)}"
  end

  def institution_name(nil) do
    "ø"
  end

  def institution_name(institution) do
    institution.name
  end
end
