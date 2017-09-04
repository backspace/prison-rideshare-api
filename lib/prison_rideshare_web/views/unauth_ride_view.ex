defmodule PrisonRideshareWeb.UnauthRideView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes [:start, :end, :initials]

  def type(_, _), do: "ride"

  has_one :institution,
    include: true,
    serializer: PrisonRideshareWeb.InstitutionView

  def initials(ride, _conn) do
    PrisonRideshareWeb.Person.initials(ride.driver)
  end
end
