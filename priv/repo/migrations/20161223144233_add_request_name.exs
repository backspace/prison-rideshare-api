defmodule PrisonRideshare.Repo.Migrations.AddRequestName do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :name, :string
    end
  end
end
