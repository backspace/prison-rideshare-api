defmodule PrisonRideshare.Repo.Migrations.ChangeNotesToText do
  use Ecto.Migration

  def up do
    alter table(:rides) do
      modify(:request_notes, :text)
    end
  end

  def down do
    alter table(:rides) do
      modify(:request_notes, :string)
    end
  end
end
