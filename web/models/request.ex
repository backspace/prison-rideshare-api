defmodule PrisonRideshare.Request do
  use PrisonRideshare.Web, :model

  schema "requests" do
    field :date, Ecto.Date
    field :start, Ecto.Time
    field :end, Ecto.Time
    field :address, :string
    field :contact, :string
    field :passengers, :integer
    field :notes, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date, :start, :end, :address, :contact, :passengers, :notes])
    |> validate_required([:date, :start, :end, :address, :contact, :passengers])
  end
end
