defmodule PrisonRideshare.Repo.Migrations.AddInstitutionFar do
  use Ecto.Migration

  def change do
    alter table(:institutions) do
      add(:far, :boolean)
    end
  end
end
