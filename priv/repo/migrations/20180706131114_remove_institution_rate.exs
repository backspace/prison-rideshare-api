defmodule PrisonRideshare.Repo.Migrations.RemoveInstitutionRate do
  use Ecto.Migration

  def change do
    alter table(:institutions) do
      remove(:rate)
    end
  end
end
