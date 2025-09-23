defmodule PrisonRideshare.Repo.Migrations.AddPersonCalendarToken do
  use Ecto.Migration

  def up do
    alter table(:people) do
      add(:calendar_secret, :string)
    end
  end

  def down do
    alter table(:people) do
      remove(:calendar_secret)
    end
  end
end
