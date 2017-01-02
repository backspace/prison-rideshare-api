defmodule PrisonRideshare.Repo.Migrations.ConvertToMoney do
  use Ecto.Migration

  def up do
    alter table(:institutions) do
      modify :rate, :integer
    end
  end

  def down do
    alter table(:institutions) do
      modify :rate, :float
    end
  end
end
