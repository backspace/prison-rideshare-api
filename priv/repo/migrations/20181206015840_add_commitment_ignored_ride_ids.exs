defmodule PrisonRideshare.Repo.Migrations.AddRideIgnoredCommitmentIds do
  use Ecto.Migration

  def change do
    alter table(:rides) do
      add(:ignored_commitment_ids, {:array, :binary_id}, default: [])
    end
  end
end
