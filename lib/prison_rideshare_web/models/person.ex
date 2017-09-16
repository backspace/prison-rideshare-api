defmodule PrisonRideshareWeb.Person do
  use PrisonRideshareWeb, :model

  schema "people" do
    field :name, :string
    field :email, :string
    field :mobile, :string
    field :landline, :string
    field :notes, :string

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
    |> cast(params, [:name, :email, :mobile, :landline, :notes])
    |> validate_required([:name, :email])
    |> validate_required_inclusion([:mobile, :landline])
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

  # Adapted from https://stackoverflow.com/a/42212602/760389
  def validate_required_inclusion(changeset, fields) do
    if Enum.any?(fields, &present?(changeset, &1)) do
      changeset
    else
      Enum.reduce(fields, changeset, fn(field, changeset) ->
        other_field = hd(fields -- [field])
        add_error(changeset, field, "or #{other_field} must be present")
      end)
    end
  end

  def present?(changeset, field) do
    value = get_field(changeset, field)
    value && value != ""
  end
end
