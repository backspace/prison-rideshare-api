defmodule PrisonRideshareWeb.CommitmentView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  has_one :person,
    type: "people",
    serializer: PrisonRideshareWeb.PersonView,
    include: false

  has_one :slot,
    type: "slots",
    serializer: PrisonRideshareWeb.SlotView,
    include: false
end
