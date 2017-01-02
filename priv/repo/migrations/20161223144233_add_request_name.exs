defmodule PrisonRideshare.Repo.Migrations.AddRideName do
  use Ecto.Migration

  def change do
    alter table(:rides) do
      add :name, :string
    end
  end
end
