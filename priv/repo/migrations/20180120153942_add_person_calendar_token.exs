defmodule PrisonRideshare.Repo.Migrations.AddPersonCalendarToken do
  use Ecto.Migration

  def up do
    alter table(:people) do
      add(:calendar_secret, :string)
    end

    flush()

    PrisonRideshare.Repo.all(PrisonRideshareWeb.Person)
    |> Enum.each(fn person ->
      Ecto.Changeset.change(
        person,
        calendar_secret: PrisonRideshare.Secret.autogenerate()
      )
      |> PrisonRideshare.Repo.update!()
    end)
  end

  def down do
    alter table(:people) do
      remove(:calendar_secret)
    end
  end
end
