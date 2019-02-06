defmodule PrisonRideshare.Repo.Migrations.AddPersonMailingAddress do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add(:address, :string)
    end
  end
end
