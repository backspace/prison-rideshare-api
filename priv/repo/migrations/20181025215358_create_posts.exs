defmodule PrisonRideshare.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:content, :text)
      add(:poster_id, references(:users, type: :binary_id))

      timestamps()
    end
  end
end
