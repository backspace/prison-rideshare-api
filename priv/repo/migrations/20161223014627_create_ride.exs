defmodule PrisonRideshare.Repo.Migrations.CreateRide do
  use Ecto.Migration

  def change do
    create table(:rides, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:start, :utc_datetime)
      add(:end, :utc_datetime)
      add(:name, :string)
      add(:address, :string)
      add(:contact, :string)
      add(:passengers, :integer, default: 1)
      add(:request_notes, :string)
      add(:enabled, :boolean, default: true)
      add(:cancellation_reason, :string)

      add(:rate, :integer)
      add(:distance, :integer)
      add(:food_expenses, :integer)
      add(:car_expenses, :integer)
      add(:report_notes, :text)
      add(:donation, :boolean, default: false)

      add(:combined_with_ride_id, references(:rides, type: :binary_id))

      timestamps()
    end

    create(index(:rides, [:combined_with_ride_id]))
  end
end
