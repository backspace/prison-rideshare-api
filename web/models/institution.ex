defmodule PrisonRideshare.Institution do
  use PrisonRideshare.Web, :model

  schema "institutions" do
    field :name, :string
    field :rate, Money.Ecto.Type

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :rate])
    |> validate_required([:name, :rate])
  end
end
