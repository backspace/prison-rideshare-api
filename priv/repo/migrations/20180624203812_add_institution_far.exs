defmodule PrisonRideshare.Repo.Migrations.AddInstitutionFar do
  use Ecto.Migration

  def up do
    alter table(:institutions) do
      add(:far, :boolean)
    end

    execute("""
      update institutions set far = true where rate = 20
    """)
  end

  def down do
    alter table(:institutions) do
      remove(:far)
    end
  end
end
