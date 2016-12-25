defmodule PrisonRideshare.Integration.Reports do
  use PrisonRideshare.ConnCase

  use Hound.Helpers

  alias PrisonRideshare.Pages.Top
  alias PrisonRideshare.Pages.NewReport
  import NewReport

  alias PrisonRideshare.Repo
  alias PrisonRideshare.User

  hound_session

  test "submitting a report (eventually) marks the request as filled" do
    # FIXME unable to create with Forge: Failed to update lockable attributes [password: {"can't be blank", []}]
    User.changeset(%User{}, %{name: "test", admin: true, email: "test@example.com", password: "test", password_confirmation: "test", confirmed_at: DateTime.utc_now})
    |> Repo.insert!

    {_, milner} = Forge.saved_institution name: "Milner Ridge"
    {_, stony} = Forge.saved_institution name: "Stony Mountain"

    Forge.saved_request institution: stony, date: Ecto.Date.from_erl({2016, 12, 30}), start: Ecto.Time.from_erl({14, 30, 0})
    Forge.saved_request institution: milner, date: Ecto.Date.from_erl({2016, 12, 29}), start: Ecto.Time.from_erl({8, 30, 0})

    set_window_size current_window_handle, 1024, 768
    navigate_to "/"

    Top.ReportLink.click_

    NewReport
    |> fill_distance("25.5")
    |> fill_food("10.11")
    |> fill_notes("Ere I saw Elba")

    assert NewReport.Requests.get(0) |> NewReport.Requests.label == "8:30 am on Thu, Dec 29 to Milner Ridge"
    assert NewReport.Requests.get(1) |> NewReport.Requests.label == "2:30 pm on Fri, Dec 30 to Stony Mountain"

    NewReport.Requests.get(1) |> NewReport.Requests.click_

    NewReport
    |> submit

    assert Top.info_alert == "Report created successfully."

    navigate_to "/reports"

    assert Top.error_alert == "You do not have the proper authorisation to do that"

    navigate_to "/sessions/new"
    set_window_size current_window_handle, 1024, 768

    fill_field({:css, "#session_email"}, "test@example.com")
    fill_field({:css, "#session_password"}, "test")
    click({:css, "button[type=submit]"})

    Top.RequestsLink.click_

    # FIXME replace with page object method
    assert has_class?({:css, "tbody tr:nth-child(1)"}, "complete")
    refute has_class?({:css, "tbody tr:nth-child(2)"}, "complete")
  end
end
