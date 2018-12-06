defmodule PrisonRideshareWeb.Commitment do
  use PrisonRideshareWeb, :model

  schema "commitments" do
    belongs_to(:slot, PrisonRideshareWeb.Slot)
    belongs_to(:person, PrisonRideshareWeb.Person)
    field(:ignored_ride_ids, {:array, :binary_id}, default: [])

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:person_id, :slot_id])
  end
end
