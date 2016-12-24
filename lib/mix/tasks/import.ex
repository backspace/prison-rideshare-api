defmodule Mix.Tasks.Import do
  use Mix.Task

  alias PrisonRideshare.{Institution, Repo, Request}

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
    |> Enum.reduce(%{}, fn({row, i}, institution_name_to_model) ->
      if i > 0 do
        [_, date, institution, start_time, end_time, address, name, contact, passengers, _, _, _, _, notes | _] = row
        matching_institution = String.downcase(institution)
        matching_institution = Map.get(institution_spelling_overrides, matching_institution, matching_institution)

        institution_name_to_model = Map.put_new_lazy(institution_name_to_model, matching_institution, fn ->
          rate = Map.get(institution_rate_overrides, matching_institution, 25)

          Institution.changeset(%Institution{}, %{name: institution, rate: rate})
          |> Repo.insert!
        end)

        institution_model = Map.get(institution_name_to_model, matching_institution)

        request_attrs = Map.put(valid_attrs, :address, (if address != "", do: address, else: "MISSING"))
        |> Map.put(:date, Timex.parse!(date, "{M}/{D}/{YYYY}"))
        |> Map.put(:start, Timex.parse!(start_time, "{h12}:{m}:{s} {AM}"))
        |> Map.put(:end, Timex.parse!(end_time, "{h12}:{m}:{s} {AM}"))
        |> Map.put(:name, name)
        |> Map.put(:contact, contact)
        |> Map.put(:passengers, passengers)
        |> Map.put(:notes, notes)
        |> Map.put(:institution_id, institution_model.id)

        Request.changeset(%Request{}, request_attrs)
        |> Repo.insert!

        institution_name_to_model
      else
        institution_name_to_model
      end
    end)
  end
end
