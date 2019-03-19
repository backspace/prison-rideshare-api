defmodule PrisonRideshareWeb.UserChannelTest do
  use PrisonRideshareWeb.ChannelCase

  alias PrisonRideshareWeb.UserChannel

  setup do
    user = Repo.insert!(%User{email: "test@example.com", admin: true, id: Ecto.UUID.generate()})
    {:ok, _, guardian_default_claims} = PrisonRideshare.Guardian.encode_and_sign(user)

    {:ok, _, socket} =
      socket("user_id", %{guardian_default_claims: guardian_default_claims})
      |> subscribe_and_join(UserChannel, "user:presence")

    {:ok, socket: socket}
  end

  test "announces joins and leaves", %{socket: _} do
    other_user = Repo.insert!(%User{email: "other@example.com", id: Ecto.UUID.generate()})
    {:ok, _, guardian_default_claims} = PrisonRideshare.Guardian.encode_and_sign(other_user)

    {:ok, _, socket} =
      socket("user_id", %{guardian_default_claims: guardian_default_claims})
      |> subscribe_and_join(UserChannel, "user:presence")

    leave(socket)

    other_user_id_string = "User:" <> other_user.id

    assert_push("presence_diff", %{
      joins: %{^other_user_id_string => _},
      leaves: %{}
    })

    assert_push("presence_diff", %{
      joins: %{},
      leaves: %{^other_user_id_string => _}
    })
  end
end
