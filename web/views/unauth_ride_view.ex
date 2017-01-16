defmodule PrisonRideshare.UnauthRideView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:start, :end]

  def type(_, _), do: "ride"

  has_one :institution,
    include: true,
    serializer: PrisonRideshare.InstitutionView
end
