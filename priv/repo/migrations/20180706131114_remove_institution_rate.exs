defmodule PrisonRideshare.Repo.Migrations.RemoveInstitutionRate do
  use Ecto.Migration

  def up do
    alter table(:institutions) do
      remove(:rate)
    end
  end

  def down do
    alter table(:institutions) do
      add(:rate, :integer)
    end
  end
end
