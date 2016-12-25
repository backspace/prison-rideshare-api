defmodule PrisonRideshare.Integration.Auth do
  use PrisonRideshare.ConnCase
  use PrisonRideshare.IntegrationHelper

  use Hound.Helpers

  alias PrisonRideshare.Pages.Top
  alias PrisonRideshare.Pages.Requests

  alias PrisonRideshare.Repo
  alias PrisonRideshare.User

  hound_session

  test "only a login link is visible when not logged in" do
    navigate_to "/"

    # FIXME add components to PageObject?
    refute apply(Hound.Matchers, :element?, (Top.requests_link))
    refute apply(Hound.Matchers, :element?, (Top.logout_link))
  end

  test "only a logout link is visible when logged in as a non-admin and a visit to requests is bounced" do
    User.changeset(%User{}, %{name: "test", admin: false, email: "non-admin@example.com", password: "test", password_confirmation: "test", confirmed_at: DateTime.utc_now})
    |> Repo.insert!

    navigate_to "/sessions/new"
    fill_field({:css, "#session_email"}, "non-admin@example.com")
    fill_field({:css, "#session_password"}, "test")
    click({:css, "button[type=submit]"})

    navigate_to "/"

    refute apply(Hound.Matchers, :element?, (Top.requests_link))
    assert apply(Hound.Matchers, :element?, (Top.logout_link))

    Requests.visit

    assert Top.error_alert == "You do not have the proper authorisation to do that"
  end

  test "when logged in, request, institution, and logout links are visible" do
    navigate_to "/sessions/new"
    fill_field({:css, "#session_email"}, "test@example.com")
    fill_field({:css, "#session_password"}, "test")
    click({:css, "button[type=submit]"})

    navigate_to "/"

    assert apply(Hound.Matchers, :element?, (Top.requests_link))
    assert apply(Hound.Matchers, :element?, (Top.logout_link))
  end
end
