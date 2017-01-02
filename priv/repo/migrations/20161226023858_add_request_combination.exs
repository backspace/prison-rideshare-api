defmodule PrisonRideshare.Repo.Migrations.AddRideCombination do
  use Ecto.Migration

  def change do
    alter table(:rides) do
      add :combined_with_ride_id, references(:rides, type: :binary_id)
    end

    create index(:rides, [:combined_with_ride_id])
  end
end
