defmodule PrisonRideshare.Repo.Migrations.AddRidesComplete do
  use Ecto.Migration

  def up do
    alter table(:rides) do
      add(:complete, :boolean, default: false)
    end

    execute("""
      update rides set complete = true where distance > 0 or car_expenses > 0
    """)
  end

  def down do
    alter table(:rides) do
      remove(:complete)
    end
  end
end
