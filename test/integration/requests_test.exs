defmodule PrisonRideshare.Integration.Requests do
  use PrisonRideshare.ConnCase

  use Hound.Helpers

  alias PrisonRideshare.Pages.NewRequest
  import NewRequest

  alias PrisonRideshare.Pages.Requests

  alias PrisonRideshare.Repo
  alias PrisonRideshare.User

  hound_session

  test "list requests and create one" do
    # FIXME unable to create with Forge: Failed to update lockable attributes [password: {"can't be blank", []}]
    User.changeset(%User{}, %{name: "test", email: "test@example.com", password: "test", password_confirmation: "test", confirmed_at: DateTime.utc_now})
    |> Repo.insert!

    # Forge.saved_user name: "test", email: "test@example.com", password: "test", password_confirmation: "test", confirmed_at: Ecto.DateTime.utc

    {_, milner} = Forge.saved_institution name: "Milner Ridge"
    Forge.saved_institution name: "Stony Mountain"

    Forge.saved_request name: "Francine", contact: "5551212", institution: milner

    navigate_to "/sessions/new"
    fill_field({:css, "#session_email"}, "test@example.com")
    fill_field({:css, "#session_password"}, "test")
    click({:css, "button[type=submit]"})

    Requests.visit

    request = Requests.Requests.get(0)
    assert(Requests.Requests.name(request) == "Francine")
    assert(Requests.Requests.contact(request) == "5551212")
    assert(Requests.Requests.institution(request) == "Milner Ridge")

    Requests.create

    NewRequest
    |> fill_start("11:30:00")
    |> fill_end("12:30:00")
    |> fill_name("Pascal")
    |> fill_address("91 Albert St.")
    |> fill_contact("5551313")
    |> fill_passengers("2")

    NewRequest.Institutions.get(1)
    |> NewRequest.Institutions.click_

    NewRequest.submit

    new_request = Requests.Requests.get(1)
    assert Requests.Requests.start(new_request) == "11:30:00"
    assert Requests.Requests.end(new_request) == "12:30:00"
    assert Requests.Requests.name(new_request) == "Pascal"
    assert Requests.Requests.institution(new_request) == "Stony Mountain"
  end
end
