defmodule PrisonRideshare.ReportView do
  use PrisonRideshare.Web, :view

  def format_request(request) do
    # TODO does this appending of the date indicate a data model problem?
    time = Timex.format({Ecto.Date.to_erl(request.date), Ecto.Time.to_erl(request.start)}, "{h12}:{m} {am}")
    |> valid_date!

    date = Timex.format(Ecto.Date.to_erl(request.date), "{WDshort}, {Mshort} {D}")
    |> valid_date!

    "#{time} on #{date} to #{institution_name(request.institution)}"
  end

  def institution_name(nil) do
    "ø"
  end

  def institution_name(institution) do
    institution.name
  end

  defp valid_date!({:ok, date}) do
    date
  end
end
