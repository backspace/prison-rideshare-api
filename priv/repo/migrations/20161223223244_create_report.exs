defmodule PrisonRideshare.Repo.Migrations.CreateReport do
  use Ecto.Migration

  def change do
    create table(:reports, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :distance, :float
      add :food, :float
      add :notes, :string
      add :request_id, references(:requests, on_delete: :nothing, type: :binary_id)

      timestamps()
    end
    create index(:reports, [:request_id])

  end
end
