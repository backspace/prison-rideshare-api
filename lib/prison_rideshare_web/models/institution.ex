defmodule PrisonRideshareWeb.Institution do
  use PrisonRideshareWeb, :model

  schema "institutions" do
    field(:name, :string)
    field(:rate, Money.Ecto.Type)
    field(:far, :boolean)

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :rate, :far])
    |> validate_required([:name, :rate, :far])
  end
end
