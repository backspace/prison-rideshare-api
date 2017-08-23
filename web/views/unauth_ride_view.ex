defmodule PrisonRideshare.UnauthRideView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:start, :end, :initials]

  def type(_, _), do: "ride"

  has_one :institution,
    include: true,
    serializer: PrisonRideshare.InstitutionView

  def initials(ride, _conn) do
    PrisonRideshare.Person.initials(ride.driver)
  end
end
