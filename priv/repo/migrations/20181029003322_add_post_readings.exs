defmodule PrisonRideshare.Repo.Migrations.AddPostReadings do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:readings, {:array, :binary_id})
    end
  end
end
