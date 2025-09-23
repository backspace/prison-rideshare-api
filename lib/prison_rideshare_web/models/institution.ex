defmodule PrisonRideshareWeb.Institution do
  use PrisonRideshareWeb, :model

  schema "institutions" do
    field(:name, :string)
    field(:far, :boolean)

    timestamps(type: :naive_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :far])
    |> validate_required([:name, :far])
  end
end
