defmodule PrisonRideshare.Request do
  use PrisonRideshare.Web, :model
  import Ecto.Query

  schema "requests" do
    field :date, Ecto.Date
    field :start, Ecto.Time
    field :end, Ecto.Time
    field :name, :string
    field :address, :string
    field :contact, :string
    field :passengers, :integer, default: 1
    field :notes, :string

    belongs_to :combined_with, PrisonRideshare.Request, foreign_key: :combined_with_request_id

    belongs_to :institution, PrisonRideshare.Institution
    has_one :report, PrisonRideshare.Report

    belongs_to :car_owner, PrisonRideshare.Person, foreign_key: :car_owner_id
    belongs_to :driver, PrisonRideshare.Person, foreign_key: :driver_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date, :start, :end, :name, :address, :contact, :passengers, :notes, :combined_with_request_id, :institution_id, :driver_id, :car_owner_id])
    |> validate_required([:date, :start, :end, :name, :address, :contact, :passengers])
  end

  def sorted(query) do
    from r in query,
    order_by: [r.date]
  end
end
