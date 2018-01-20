defmodule PrisonRideshare.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:email, :string)
      add(:password_hash, :string)
      add(:admin, :boolean, default: false)

      timestamps()
    end

    create(index(:users, [:email], unique: true))
  end
end
