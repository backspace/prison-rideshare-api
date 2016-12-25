defmodule PrisonRideshare.Person do
  use PrisonRideshare.Web, :model

  schema "people" do
    field :name, :string
    has_many :car_uses, PrisonRideshare.Request, foreign_key: :car_owner_id
    has_many :drivings, PrisonRideshare.Request, foreign_key: :driver_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  def sorted(query) do
    from r in query,
    order_by: [r.name]
  end
end
