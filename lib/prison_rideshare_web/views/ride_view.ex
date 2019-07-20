defmodule PrisonRideshareWeb.RideView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :start,
    :end,
    :initials,
    :name,
    :address,
    :contact,
    :first_time,
    :medium,
    :request_confirmed,
    :passengers,
    :request_notes,
    :enabled,
    :complete,
    :cancellation_reason,
    :distance,
    :rate,
    :food_expenses,
    :car_expenses,
    :report_notes,
    :donation,
    :donatable,
    :overridable,
    :inserted_at,
    :updated_at
  ])

  has_one(
    :combined_with,
    field: :combined_with_ride_id,
    type: "ride"
  )

  has_many(:children, type: "ride")

  has_many(
    :reimbursements,
    type: "reimbursement",
    include: true,
    serializer: PrisonRideshareWeb.ReimbursementView
  )

  has_one(
    :institution,
    include: true,
    serializer: PrisonRideshareWeb.InstitutionView
  )

  has_one(
    :driver,
    include: true,
    serializer: PrisonRideshareWeb.PersonView
  )

  has_one(
    :car_owner,
    include: true,
    serializer: PrisonRideshareWeb.PersonView
  )

  money_amount(:rate)
  money_amount(:food_expenses)
  money_amount(:car_expenses)

  def initials(ride, _conn) do
    PrisonRideshareWeb.Person.initials(ride.driver)
  end

  def donatable(ride, _) do
    ride.driver_id == ride.car_owner_id
  end

  def start(%{start: nil}, _conn), do: nil
  def start(%{start: start}, _conn), do: "#{Ecto.DateTime.to_iso8601(start)}Z"

  def unquote(:end)(%{end: nil}, _conn), do: nil
  def unquote(:end)(%{end: end_time}, _conn), do: "#{Ecto.DateTime.to_iso8601(end_time)}Z"
end
