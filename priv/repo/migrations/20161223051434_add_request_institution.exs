defmodule PrisonRideshare.Repo.Migrations.AddRequestInstitution do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :institution_id, references(:institutions, type: :binary_id)
    end
  end
end
