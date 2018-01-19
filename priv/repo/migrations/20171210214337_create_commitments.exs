defmodule PrisonRideshare.Repo.Migrations.CreateCommitments do
  use Ecto.Migration

  def change do
    create table(:commitments, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(:slot_id, references(:slots, on_delete: :delete_all, type: :binary_id))
      add(:person_id, references(:people, on_delete: :delete_all, type: :binary_id))

      timestamps()
    end
  end
end
