defmodule PrisonRideshare.Repo.Migrations.CreateInstitution do
  use Ecto.Migration

  def change do
    create table(:institutions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :rate, :float

      timestamps()
    end

  end
end
