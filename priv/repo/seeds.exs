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

PrisonRideshare.Repo.delete_all PrisonRideshare.User

user = PrisonRideshare.User.changeset(%PrisonRideshare.User{}, %{
  name: "Test User",
  email: "testuser@example.com",
  password: "secretsecret",
  password_confirmation: "secretsecret",
  confirmed_at: Ecto.DateTime.utc
})
|> PrisonRideshare.Repo.insert!

PrisonRideshare.User.admin_changeset(user, %{admin: true})
|> PrisonRideshare.Repo.update!
