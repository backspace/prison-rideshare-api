defmodule PrisonRideshare.RideView do
  use PrisonRideshare.Web, :view

  def format_ride_times(ride) do
    start_string = Timex.format!({Ecto.Date.to_erl(ride.date), Ecto.Time.to_erl(ride.start)}, "{h12}:{m} {AM}")
    end_string = Timex.format!({Ecto.Date.to_erl(ride.date), Ecto.Time.to_erl(ride.end)}, "{h12}:{m}")

    "#{start_string} — #{end_string}"
  end
end
