defmodule PrisonRideshare.RideView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:start, :end, :name, :address, :contact, :passengers, :request_notes, :enabled, :cancellation_reason, :distance, :rate, :food_expenses, :car_expenses, :report_notes, :inserted_at, :updated_at]

  has_one :combined_with,
    field: :combined_with_ride_id,
    type: "ride"
  has_many :children,
    type: "ride"

  has_one :institution,
    include: true,
    serializer: PrisonRideshare.InstitutionView
  has_one :driver,
    include: true,
    serializer: PrisonRideshare.PersonView
  has_one :car_owner,
    include: true,
    serializer: PrisonRideshare.PersonView

  money_amount :rate
  money_amount :food_expenses
  money_amount :car_expenses
end
