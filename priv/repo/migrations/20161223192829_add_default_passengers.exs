defmodule PrisonRideshare.Repo.Migrations.AddDefaultPassengers do
  use Ecto.Migration

  def up do
    alter table(:requests) do
      modify :passengers, :integer, default: 1
    end
  end

  def down do
    alter table(:requests) do
      modify :passengers, :integer
    end
  end
end
