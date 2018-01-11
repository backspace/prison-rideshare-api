defmodule PrisonRideshare.Repo.Migrations.AddPersonActive do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :active, :boolean, default: true
    end
  end
end
