defmodule PrisonRideshareWeb.Ride do
  use PrisonRideshareWeb, :model

  schema "rides" do
    field :start, Ecto.DateTime
    field :end, Ecto.DateTime
    field :name, :string
    field :address, :string
    field :contact, :string
    field :passengers, :integer, default: 1
    field :request_notes, :string
    field :enabled, :boolean, default: true
    field :cancellation_reason, :string

    field :distance, :integer
    field :rate, Money.Ecto.Type
    field :food_expenses, Money.Ecto.Type, default: 0
    field :car_expenses, Money.Ecto.Type, default: 0
    field :report_notes, :string
    field :donation, :boolean, default: false

    # FIXME now that both ends of this seem necessary, the naming is awkward.
    belongs_to :combined_with, PrisonRideshareWeb.Ride, foreign_key: :combined_with_ride_id
    has_many :children, PrisonRideshareWeb.Ride, foreign_key: :combined_with_ride_id

    belongs_to :institution, PrisonRideshareWeb.Institution

    belongs_to :car_owner, PrisonRideshareWeb.Person, foreign_key: :car_owner_id
    belongs_to :driver, PrisonRideshareWeb.Person, foreign_key: :driver_id

    has_many :reimbursements, PrisonRideshareWeb.Reimbursement

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start, :end, :name, :address, :contact, :passengers, :request_notes, :enabled, :cancellation_reason, :combined_with_ride_id, :institution_id, :driver_id, :car_owner_id, :distance, :rate, :food_expenses, :car_expenses, :report_notes, :donation])
    |> validate_required([:start, :end, :name, :address, :contact, :passengers])
  end

  def report_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:distance, :food_expenses, :report_notes, :donation])
    |> validate_required([:distance, :food_expenses])
    |> calculate_car_expenses(struct)
  end

  defp calculate_car_expenses(%{valid?: false} = changeset, _), do: changeset
  defp calculate_car_expenses(%{valid?: true} = changeset, struct) do
    distance = Ecto.Changeset.get_field(changeset, :distance)
    institution = Ecto.Changeset.get_field(changeset, :institution)
    Ecto.Changeset.put_change(changeset, :rate, institution.rate)
    |> Ecto.Changeset.put_change(:car_expenses, Money.multiply(institution.rate, distance))
  end
end