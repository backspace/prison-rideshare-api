defmodule PrisonRideshare.Repo.Migrations.AddRequestPeople do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :car_owner_id, references(:people)
      add :driver_id, references(:people)
    end

    create index(:requests, [:car_owner_id])
    create index(:requests, [:driver_id])
  end
end
