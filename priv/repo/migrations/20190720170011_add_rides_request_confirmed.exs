defmodule PrisonRideshare.Repo.Migrations.AddRidesRequestConfirmed do
  use Ecto.Migration

  def up do
    alter table(:rides) do
      add(:request_confirmed, :boolean)
    end

    execute("""
      update rides set request_confirmed = true
    """)
  end

  def down do
    alter table(:rides) do
      remove(:request_confirmed)
    end
  end
end
