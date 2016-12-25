defmodule PrisonRideshare.Report do
  use PrisonRideshare.Web, :model

  schema "reports" do
    field :distance, :float
    field :rate, Money.Ecto.Type
    field :food, Money.Ecto.Type
    field :notes, :string
    belongs_to :request, PrisonRideshare.Request

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:distance, :food, :notes, :request_id, :rate])
    |> validate_required([:distance, :food])
  end
end
