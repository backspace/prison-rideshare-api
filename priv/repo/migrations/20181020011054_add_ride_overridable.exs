defmodule PrisonRideshare.Repo.Migrations.AddRideOverridable do
  use Ecto.Migration

  def change do
    alter table(:rides) do
      add(:overridable, :boolean)
    end
  end
end
