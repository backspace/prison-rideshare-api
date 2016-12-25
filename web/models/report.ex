defmodule PrisonRideshare.Report do
  use PrisonRideshare.Web, :model

  schema "reports" do
    field :distance, :float
    field :expenses, Money.Ecto.Type
    field :notes, :string
    belongs_to :request, PrisonRideshare.Request

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:distance, :expenses, :notes, :request_id])
    |> validate_required([:distance, :expenses])
  end
end
