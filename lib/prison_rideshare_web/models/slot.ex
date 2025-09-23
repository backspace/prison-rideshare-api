defmodule PrisonRideshareWeb.Slot do
  use PrisonRideshareWeb, :model

  schema "slots" do
    field(:start, :naive_datetime)
    field(:end, :naive_datetime)
    field(:count, :integer, default: 0)

    has_many(:commitments, PrisonRideshareWeb.Commitment)

    timestamps(type: :naive_datetime)
  end
end
