defmodule PrisonRideshare.Reimbursement do
  use PrisonRideshare.Web, :model

  schema "reimbursements" do
    field :car_expenses, Money.Ecto.Type, default: 0
    field :food_expenses, Money.Ecto.Type, default: 0
    belongs_to :person, PrisonRideshare.Person
    belongs_to :ride, PrisonRideshare.Ride

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    # FIXME the JaSerializer generator didn’t include person_id here, probably wrong but
    # currently relied upon in import code. (And ride_id now too.)
    |> cast(params, [:car_expenses, :food_expenses, :person_id, :ride_id])
  end
end
