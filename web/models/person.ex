defmodule PrisonRideshare.Person do
  use PrisonRideshare.Web, :model

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
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  def initials(%{name: ""}), do: "??"
  def initials(%{name: nil}), do: "??"
  def initials(nil), do: "??"

  def initials(%{name: name}) do
    String.split(name, ~r/ |-/)
    |> Enum.reject(fn(part) -> part == "" end)
    |> Enum.map(fn(word) -> String.first(word) |> String.upcase end)
    |> Enum.join
  end
end
