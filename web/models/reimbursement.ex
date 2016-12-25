defmodule PrisonRideshare.Reimbursement do
  use PrisonRideshare.Web, :model

  schema "reimbursements" do
    field :amount, :integer
    belongs_to :person, PrisonRideshare.Person

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:amount])
    |> validate_required([:amount])
  end
end
