defmodule PrisonRideshare.Repo.Migrations.AddRidePeople do
  use Ecto.Migration

  def change do
    alter table(:rides) do
      add :car_owner_id, references(:people, type: :binary_id)
      add :driver_id, references(:people, type: :binary_id)
    end

    create index(:rides, [:car_owner_id])
    create index(:rides, [:driver_id])
  end
end
