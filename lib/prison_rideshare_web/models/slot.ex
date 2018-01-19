defmodule PrisonRideshareWeb.Slot do
  use PrisonRideshareWeb, :model

  schema "slots" do
    field(:start, :naive_datetime)
    field(:end, :naive_datetime)
    field(:count, :integer, default: 0)

    has_many(:commitments, PrisonRideshareWeb.Commitment)

    timestamps(type: :utc_datetime)
  end
end
