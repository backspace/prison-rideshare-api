defmodule PrisonRideshare.Repo.Migrations.AddPersonMedium do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :medium, :string
    end
  end
end
