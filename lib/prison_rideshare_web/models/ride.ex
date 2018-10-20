defmodule PrisonRideshareWeb.Ride do
  use PrisonRideshareWeb, :model

  schema "rides" do
    field(:start, Ecto.DateTime)
    field(:end, Ecto.DateTime)
    field(:name, :string)
    field(:address, :string)
    field(:contact, :string)
    field(:first_time, :boolean, default: false)
    field(:medium, :string)
    field(:passengers, :integer, default: 1)
    field(:request_notes, :string)
    field(:enabled, :boolean, default: true)
    field(:cancellation_reason, :string)

    field(:distance, :integer)

    field(:rate, Money.Ecto.Type)
    belongs_to(:gas_price, PrisonRideshareWeb.GasPrice)

    field(:food_expenses, Money.Ecto.Type, default: 0)
    field(:car_expenses, Money.Ecto.Type, default: 0)
    field(:report_notes, :string)
    field(:donation, :boolean, default: false)

    field(:overridable, :boolean, default: false)

    # FIXME now that both ends of this seem necessary, the naming is awkward.
    belongs_to(:combined_with, PrisonRideshareWeb.Ride, foreign_key: :combined_with_ride_id)
    has_many(:children, PrisonRideshareWeb.Ride, foreign_key: :combined_with_ride_id)

    belongs_to(:institution, PrisonRideshareWeb.Institution)

    belongs_to(:car_owner, PrisonRideshareWeb.Person, foreign_key: :car_owner_id)
    belongs_to(:driver, PrisonRideshareWeb.Person, foreign_key: :driver_id)

    has_many(:reimbursements, PrisonRideshareWeb.Reimbursement)

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :start,
      :end,
      :name,
      :address,
      :contact,
      :first_time,
      :medium,
      :passengers,
      :request_notes,
      :enabled,
      :cancellation_reason,
      :combined_with_ride_id,
      :institution_id,
      :driver_id,
      :car_owner_id,
      :distance,
      :rate,
      :gas_price_id,
      :food_expenses,
      :car_expenses,
      :report_notes,
      :donation,
      :overridable
    ])
    |> validate_required([:start, :end, :name, :address, :contact, :passengers])
    |> calculate_car_expenses(struct)
  end

  def import_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :start,
      :end,
      :name,
      :address,
      :contact,
      :passengers,
      :request_notes,
      :enabled,
      :cancellation_reason,
      :combined_with_ride_id,
      :institution_id,
      :driver_id,
      :car_owner_id,
      :distance,
      :rate,
      :food_expenses,
      :car_expenses,
      :report_notes,
      :donation
    ])
    |> validate_required([:start, :end, :name, :address, :contact, :passengers])
  end

  def report_changeset(struct, params \\ %{})

  def report_changeset(%{overridable: true} = struct, params) do
    struct
    |> cast(params, [:distance, :car_expenses, :food_expenses, :report_notes, :donation])
    |> validate_required([:distance, :food_expenses])
  end

  def report_changeset(struct, params) do
    struct
    |> cast(params, [:distance, :food_expenses, :report_notes, :donation])
    |> validate_required([:distance, :food_expenses])
    |> calculate_car_expenses(struct)
  end

  defp calculate_car_expenses(%{valid?: false} = changeset, _), do: changeset

  # FIXME does this ever happen? What if overridable BUT no car_expenses submitted?
  defp calculate_car_expenses(%{valid?: true, overridable: true} = changeset, _), do: changeset

  defp calculate_car_expenses(%{valid?: true} = changeset, _) do
    distance = Ecto.Changeset.get_field(changeset, :distance)
    rate = Ecto.Changeset.get_field(changeset, :rate)

    calculate_car_expenses(changeset, distance, rate)
  end

  defp calculate_car_expenses(changeset, nil, _), do: changeset
  defp calculate_car_expenses(changeset, _, nil), do: changeset

  defp calculate_car_expenses(changeset, distance, rate) do
    Ecto.Changeset.put_change(changeset, :car_expenses, Money.multiply(rate, distance))
  end
end
