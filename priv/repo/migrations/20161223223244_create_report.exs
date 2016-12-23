defmodule PrisonRideshare.Repo.Migrations.CreateReport do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :distance, :float
      add :expenses, :float
      add :notes, :string
      add :request_id, references(:requests, on_delete: :nothing)

      timestamps()
    end
    create index(:reports, [:request_id])

  end
end
