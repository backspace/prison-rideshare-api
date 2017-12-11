defmodule PrisonRideshareWeb.Commitment do
  use PrisonRideshareWeb, :model

  schema "commitments" do
    belongs_to :slot, PrisonRideshareWeb.Slot
    belongs_to :person, PrisonRideshareWeb.Person

    timestamps(type: :utc_datetime)
  end
end
