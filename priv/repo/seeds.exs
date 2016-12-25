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

PrisonRideshare.User.changeset(%PrisonRideshare.User{}, %{
  name: "Test User",
  admin: true, email:
  "testuser@example.com",
  password: "secret",
  password_confirmation: "secret",
  confirmed_at: Ecto.DateTime.utc
})
|> PrisonRideshare.Repo.insert!
