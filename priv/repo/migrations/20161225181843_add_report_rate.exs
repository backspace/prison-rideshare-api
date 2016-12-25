defmodule PrisonRideshare.Repo.Migrations.AddReportRate do
  use Ecto.Migration

  def change do
    alter table(:reports) do
      add :rate, :integer
    end
  end
end
