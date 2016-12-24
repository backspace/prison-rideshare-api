defmodule PrisonRideshare.Repo.Migrations.CreatePerson do
  use Ecto.Migration

  def change do
    create table(:people) do
      add :name, :string

      timestamps()
    end

  end
end
