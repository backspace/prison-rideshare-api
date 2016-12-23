defmodule PrisonRideshare.Repo.Migrations.CreateInstitution do
  use Ecto.Migration

  def change do
    create table(:institutions) do
      add :name, :string
      add :rate, :float

      timestamps()
    end

  end
end
