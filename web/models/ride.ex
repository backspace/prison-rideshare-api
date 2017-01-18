defmodule PrisonRideshare.Ride do
  use PrisonRideshare.Web, :model
  import Ecto.Query

  schema "rides" do
    field :start, Ecto.DateTime
    field :end, Ecto.DateTime
    field :name, :string
    field :address, :string
    field :contact, :string
    field :passengers, :integer, default: 1
    field :request_notes, :string
    field :enabled, :boolean
    field :cancellation_reason, :string

    field :distance, :float
    field :rate, Money.Ecto.Type
    field :food_expenses, Money.Ecto.Type
    field :car_expenses, Money.Ecto.Type
    field :report_notes, :string

    belongs_to :combined_with, PrisonRideshare.Ride, foreign_key: :combined_with_ride_id

    belongs_to :institution, PrisonRideshare.Institution

    belongs_to :car_owner, PrisonRideshare.Person, foreign_key: :car_owner_id
    belongs_to :driver, PrisonRideshare.Person, foreign_key: :driver_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start, :end, :name, :address, :contact, :passengers, :request_notes, :enabled, :cancellation_reason, :combined_with_ride_id, :institution_id, :driver_id, :car_owner_id, :distance, :rate, :food_expenses, :car_expenses, :report_notes])
    |> validate_required([:start, :end, :name, :address, :contact, :passengers])
  end

  def report_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:distance, :food_expenses, :report_notes])
    |> validate_required([:distance, :food_expenses])
  end

  def sorted(query) do
    from r in query,
    order_by: [r.start]
  end
end
