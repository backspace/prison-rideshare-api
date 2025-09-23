defmodule PrisonRideshareWeb.CommitmentView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  def type(_, _), do: "commitments"

  has_one(
    :person,
    type: "people",
    serializer: PrisonRideshareWeb.PersonView,
    include: false
  )

  has_one(
    :slot,
    type: "slots",
    serializer: PrisonRideshareWeb.SlotView,
    include: false
  )
end
