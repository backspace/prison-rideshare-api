defmodule PrisonRideshare.Integration.Auth do
  use PrisonRideshare.ConnCase

  use Hound.Helpers

  alias PrisonRideshare.Pages.Top

  alias PrisonRideshare.Repo
  alias PrisonRideshare.User

  hound_session

  test "only a login link is visible when not logged in" do
    navigate_to "/"

    # FIXME add components to PageObject?
    refute apply(Hound.Matchers, :element?, (Top.requests_link))
    refute apply(Hound.Matchers, :element?, (Top.logout_link))
  end

  test "when logged in, request, institution, and logout links are visible" do
    # FIXME unable to create with Forge: Failed to update lockable attributes [password: {"can't be blank", []}]
    User.changeset(%User{}, %{name: "test", email: "test@example.com", password: "test", password_confirmation: "test", confirmed_at: DateTime.utc_now})
    |> Repo.insert!

    navigate_to "/sessions/new"
    fill_field({:css, "#session_email"}, "test@example.com")
    fill_field({:css, "#session_password"}, "test")
    click({:css, "button[type=submit]"})

    navigate_to "/"

    assert apply(Hound.Matchers, :element?, (Top.requests_link))
    assert apply(Hound.Matchers, :element?, (Top.logout_link))
  end
end
