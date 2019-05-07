defmodule PrisonRideshare.Repo.Migrations.AddRidesComplete do
  use Ecto.Migration

  def change do
    alter table(:rides) do
      add(:complete, :boolean, default: false)
    end
  end
end
