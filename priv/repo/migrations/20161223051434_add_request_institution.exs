defmodule PrisonRideshare.Repo.Migrations.AddRideInstitution do
  use Ecto.Migration

  def change do
    alter table(:rides) do
      add(:institution_id, references(:institutions, type: :binary_id))
    end
  end
end
