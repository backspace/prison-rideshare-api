defmodule PrisonRideshare.Request do
  use PrisonRideshare.Web, :model

  schema "requests" do
    field :date, Ecto.Date
    field :start, Ecto.Time
    field :end, Ecto.Time
    field :name, :string
    field :address, :string
    field :contact, :string
    field :passengers, :integer, default: 1
    field :notes, :string

    belongs_to :institution, PrisonRideshare.Institution
    has_one :report, PrisonRideshare.Report

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date, :start, :end, :name, :address, :contact, :passengers, :notes, :institution_id])
    |> validate_required([:date, :start, :end, :name, :address, :contact, :passengers])
  end
end
