defmodule PrisonRideshare.Repo.Migrations.AddPeopleContacts do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add(:email, :string)
      add(:mobile, :string)
      add(:landline, :string)
      add(:notes, :text)
    end
  end
end
