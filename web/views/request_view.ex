defmodule PrisonRideshare.RequestView do
  use PrisonRideshare.Web, :view

  def format_request_times(request) do
    start_string = Timex.format!({Ecto.Date.to_erl(request.date), Ecto.Time.to_erl(request.start)}, "{h12}:{m} {AM}")
    end_string = Timex.format!({Ecto.Date.to_erl(request.date), Ecto.Time.to_erl(request.end)}, "{h12}:{m}")

    "#{start_string} — #{end_string}"
  end
end
