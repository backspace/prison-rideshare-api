defmodule PrisonRideshare.Reimbursement do
  use PrisonRideshare.Web, :model

  schema "reimbursements" do
    field :amount, Money.Ecto.Type
    belongs_to :person, PrisonRideshare.Person

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    # FIXME the JaSerializer generator didn’t include person_id here, probably wrong but
    # currently relied upon in import code.
    |> cast(params, [:amount, :person_id])
    |> validate_required([:amount])
  end
end
