defmodule PrisonRideshare.Repo.Migrations.AddRequestCombination do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :combined_with_request_id, references(:requests, type: :binary_id)
    end

    create index(:requests, [:combined_with_request_id])
  end
end
