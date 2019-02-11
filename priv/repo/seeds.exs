# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PrisonRideshare.Repo.insert!(%PrisonRideshare.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

PrisonRideshare.Repo.delete_all(PrisonRideshareWeb.User)

version_information = [origin: "seeds"]

user =
  PrisonRideshareWeb.User.changeset(%PrisonRideshareWeb.User{}, %{
    name: "Test User",
    email: "testuser@example.com",
    password: "secretsecret",
    password_confirmation: "secretsecret",
    confirmed_at: Ecto.DateTime.utc()
  })
  |> PaperTrail.insert!(version_information)

PrisonRideshareWeb.User.admin_changeset(user, %{admin: true})
|> PaperTrail.update!(version_information)

PrisonRideshare.Repo.all(PrisonRideshareWeb.Person)
|> Enum.each(fn person ->
  Ecto.Changeset.change(
    person,
    calendar_secret: PrisonRideshare.Secret.autogenerate()
  )
  |> PrisonRideshare.Repo.update!()
end)
