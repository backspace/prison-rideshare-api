defmodule PrisonRideshare.Repo.Migrations.AddRidesVisitor do
  use Ecto.Migration

  def change do
    alter table(:rides) do
      add(:visitor_id, references(:people, type: :binary_id))
    end

    create(index(:rides, [:visitor_id]))
  end
end
