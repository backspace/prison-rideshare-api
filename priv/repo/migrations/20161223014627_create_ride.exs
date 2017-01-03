defmodule PrisonRideshare.Repo.Migrations.CreateRide do
  use Ecto.Migration

  def change do
    create table(:rides, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start, :datetime
      add :end, :datetime
      add :name, :string
      add :address, :string
      add :contact, :string
      add :passengers, :integer, default: 1
      add :request_notes, :string
      add :enabled, :boolean, default: true

      add :rate, :integer
      add :distance, :float
      add :food_expenses, :integer
      add :car_expenses, :integer
      add :report_notes, :string

      add :combined_with_ride_id, references(:rides, type: :binary_id)

      timestamps()
    end

    create index(:rides, [:combined_with_ride_id])

  end
end
