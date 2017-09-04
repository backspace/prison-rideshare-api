defmodule PrisonRideshareWeb.RideView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes [:start, :end, :initials, :name, :address, :contact, :passengers, :request_notes, :enabled, :cancellation_reason, :distance, :rate, :food_expenses, :car_expenses, :report_notes, :donation, :inserted_at, :updated_at]

  has_one :combined_with,
    field: :combined_with_ride_id,
    type: "ride"
  has_many :children,
    type: "ride"

  has_many :reimbursements,
    type: "reimbursement",
    include: true,
    serializer: PrisonRideshareWeb.ReimbursementView

  has_one :institution,
    include: true,
    serializer: PrisonRideshareWeb.InstitutionView
  has_one :driver,
    include: true,
    serializer: PrisonRideshareWeb.PersonView
  has_one :car_owner,
    include: true,
    serializer: PrisonRideshareWeb.PersonView

  money_amount :rate
  money_amount :food_expenses
  money_amount :car_expenses

  def initials(ride, _conn) do
    PrisonRideshareWeb.Person.initials(ride.driver)
  end
end
