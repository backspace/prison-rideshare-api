defmodule PrisonRideshare.Repo.Migrations.CreateRide do
  use Ecto.Migration

  def change do
    create table(:rides, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date
      add :start, :time
      add :end, :time
      add :address, :string
      add :contact, :string
      add :passengers, :integer
      add :request_notes, :string

      add :rate, :integer
      add :distance, :float
      add :food, :integer
      add :report_notes, :string

      timestamps()
    end

  end
end
