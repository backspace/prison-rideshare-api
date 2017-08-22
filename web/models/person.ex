defmodule PrisonRideshare.Person do
  use PrisonRideshare.Web, :model
  use Whatwasit

  schema "people" do
    field :name, :string
    has_many :car_uses, PrisonRideshare.Ride, foreign_key: :car_owner_id
    has_many :drivings, PrisonRideshare.Ride, foreign_key: :driver_id

    has_many :reimbursements, PrisonRideshare.Reimbursement

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}, opts \\ []) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
    |> prepare_version(opts)
  end
end
