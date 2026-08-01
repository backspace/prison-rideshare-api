defmodule PrisonRideshare.Repo.Migrations.ChangeRidesDistanceToDecimal do
  use Ecto.Migration

  def up do
    alter table(:rides) do
      modify(:distance, :decimal)
    end
  end

  def down do
    alter table(:rides) do
      modify(:distance, :integer)
    end
  end
end
