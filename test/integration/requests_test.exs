defmodule PrisonRideshare.Integration.Requests do
  use PrisonRideshare.ConnCase

  use Hound.Helpers

  alias PrisonRideshare.Pages.NewRequest
  import NewRequest

  alias PrisonRideshare.Pages.Top

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

    {_, bhagat} = Forge.saved_person name: "Bhagat Singh"
    {_, john} = Forge.saved_person name: "John Wojtowicz"

    Forge.saved_request name: "Francine", contact: "5551212", institution: milner, driver: bhagat, car_owner: john

    navigate_to "/sessions/new"
    set_window_size current_window_handle, 1024, 768

    fill_field({:css, "#session_email"}, "test@example.com")
    fill_field({:css, "#session_password"}, "test")
    click({:css, "button[type=submit]"})

    Top.RequestsLink.click_

    request = Requests.Requests.get(0)
    assert(Requests.Requests.name(request) == "Francine")
    assert(Requests.Requests.contact(request) == "5551212")
    assert(Requests.Requests.institution(request) == "Milner Ridge")
    assert(Requests.Requests.driver(request) == "Bhagat Singh")
    assert(Requests.Requests.car_owner(request) == "John Wojtowicz")

    Requests.create

    NewRequest
    |> fill_start_hour("11")
    |> fill_start_minute("30")
    |> fill_end_hour("12")
    |> fill_end_minute("30")
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
