defmodule PrisonRideshare.Repo.Migrations.CreateRequest do
  use Ecto.Migration

  def change do
    create table(:requests) do
      add :date, :date
      add :start, :time
      add :end, :time
      add :address, :string
      add :contact, :string
      add :passengers, :integer
      add :notes, :string

      timestamps()
    end

  end
end
