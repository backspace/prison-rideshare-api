defmodule PrisonRideshare.Repo.Migrations.AddPersonSelfNotes do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add(:self_notes, :text)
    end
  end
end
