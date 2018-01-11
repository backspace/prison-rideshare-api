defmodule PrisonRideshareWeb.Person do
  use PrisonRideshareWeb, :model

  schema "people" do
    field :name, :string
    field :email, :string
    field :mobile, :string
    field :landline, :string
    field :notes, :string
    field :medium, :string
    field :active, :boolean, default: true

    has_many :car_uses, PrisonRideshareWeb.Ride, foreign_key: :car_owner_id
    has_many :drivings, PrisonRideshareWeb.Ride, foreign_key: :driver_id

    has_many :reimbursements, PrisonRideshareWeb.Reimbursement

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :mobile, :landline, :notes, :medium, :active])
    |> validate_required([:name, :email])
  end

  def import_changeset(struct, params \\ %{}) do
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
