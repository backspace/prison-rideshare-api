defmodule PrisonRideshareWeb.UnauthRideView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes([:start, :end, :initials, :donatable, :overridable, :rate])

  def type(_, _), do: "ride"

  has_one(
    :institution,
    include: true,
    serializer: PrisonRideshareWeb.InstitutionView
  )

  def initials(ride, _conn) do
    PrisonRideshareWeb.Person.initials(ride.driver)
  end

  def donatable(ride, _) do
    ride.driver_id == ride.car_owner_id
  end

  # FIXME these are duplicated in RideView ugh
  def start(%{start: nil}, _conn), do: nil
  def start(%{start: start}, _conn), do: "#{NaiveDateTime.to_iso8601(start)}Z"

  def unquote(:end)(%{end: nil}, _conn), do: nil
  def unquote(:end)(%{end: end_time}, _conn), do: "#{NaiveDateTime.to_iso8601(end_time)}Z"

  money_amount(:rate, false)
end
