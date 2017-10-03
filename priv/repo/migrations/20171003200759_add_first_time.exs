defmodule PrisonRideshare.Repo.Migrations.AddFirstTime do
  use Ecto.Migration

  def change do
    alter table(:rides) do
      add :first_time, :boolean, default: false
    end
  end
end
