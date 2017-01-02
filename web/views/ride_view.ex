defmodule PrisonRideshare.RideView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:start, :end, :name, :address, :contact, :passengers, :request_notes, :distance, :rate, :food_expenses, :car_expenses, :report_notes, :inserted_at, :updated_at]

  has_one :combined_with,
    field: :combined_with_ride_id,
    type: "ride"
  has_one :institution,
    field: :institution_id,
    type: "institution"
  has_one :driver,
    field: :driver_id,
    type: "person"
  has_one :car_owner,
    field: :car_owner_id,
    type: "person"

  def rate(ride, _) do
    amount_or_zero(ride.rate)
  end

  def food_expenses(ride, _) do
    amount_or_zero(ride.food_expenses)
  end

  def car_expenses(ride, _) do
    amount_or_zero(ride.car_expenses)
  end

  defp amount_or_zero(nil), do: 0
  defp amount_or_zero(%{amount: amount}), do: amount
end
