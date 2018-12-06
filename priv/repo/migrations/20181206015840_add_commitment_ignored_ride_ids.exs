defmodule PrisonRideshare.Repo.Migrations.AddCommitmentIgnoredRideIds do
  use Ecto.Migration

  def change do
    alter table(:commitments) do
      add(:ignored_ride_ids, {:array, :binary_id})
    end
  end
end
