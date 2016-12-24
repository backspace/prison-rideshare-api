defmodule Mix.Tasks.Import do
  use Mix.Task

  alias PrisonRideshare.{Repo, Request}

  @shortdoc "Imports CSVs"

  def run(args) do
    Mix.Task.run "app.start"

    [requests] = OptionParser.split(args)

    valid_attrs = %{name: "some content", address: "some content", contact: "some content", date: %{day: 17, month: 4, year: 2010}, end: %{hour: 14, min: 0, sec: 0}, notes: "some content", passengers: 42, start: %{hour: 14, min: 0, sec: 0}}

    File.stream!(requests)
    |> CSV.decode
    |> Enum.with_index
    |> Enum.each(fn {row, i} ->
      if i > 0 do
        [_, _, _, _, _, address | _] = row
        request_attrs = Map.put(valid_attrs, :address, address)

        Request.changeset(%Request{}, request_attrs)
        |> Repo.insert!
      end
    end)
  end
end
