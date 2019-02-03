defmodule PrisonRideshare.Repo.Migrations.ChangeNotesToText do
  use Ecto.Migration

  def change do
    alter table(:rides) do
      modify(:request_notes, :text)
    end
  end
end
