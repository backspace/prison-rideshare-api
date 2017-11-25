defmodule PrisonRideshare.Repo.Migrations.AddRideMedium do
  use Ecto.Migration

  def change do
    alter table(:rides) do
      add :medium, :string
    end
  end
end
