defmodule PrisonRideshareWeb.Reimbursement do
  use PrisonRideshareWeb, :model

  schema "reimbursements" do
    field(:car_expenses, Money.Ecto.Type, default: 0)
    field(:food_expenses, Money.Ecto.Type, default: 0)
    belongs_to(:person, PrisonRideshareWeb.Person)
    belongs_to(:ride, PrisonRideshareWeb.Ride)

    field(:donation, :boolean, default: false)
    field(:processed, :boolean, default: false)

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    # FIXME the JaSerializer generator didn’t include person_id here, probably wrong but
    # currently relied upon in import code. (And ride_id now too.)
    struct
    |> cast(params, [:car_expenses, :food_expenses, :person_id, :ride_id, :donation, :processed])
  end

  def import_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :car_expenses,
      :food_expenses,
      :person_id,
      :ride_id,
      :donation,
      :processed,
      :inserted_at,
      :updated_at
    ])
  end
end
