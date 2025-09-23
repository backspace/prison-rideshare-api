defmodule PrisonRideshare.Repo.Migrations.AddRidesInstitutionConstraint do
  use Ecto.Migration

  def up do
    drop(constraint(:rides, "rides_institution_id_fkey"))

    alter table(:rides) do
      modify(:institution_id, references(:institutions, type: :binary_id), null: false)
    end
  end

  def down do
    drop(constraint(:rides, "rides_institution_id_fkey"))

    alter table(:rides) do
      modify(:institution_id, references(:institutions, type: :binary_id), null: true)
    end
  end
end
