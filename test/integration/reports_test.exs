defmodule PrisonRideshare.Integration.Reports do
  use PrisonRideshare.ConnCase
  use PrisonRideshare.IntegrationHelper

  use Hound.Helpers

  alias PrisonRideshare.Pages.Top
  alias PrisonRideshare.Pages.NewReport
  alias PrisonRideshare.Pages.Reports
  import NewReport

  hound_session

  test "submitting a report (eventually) marks the request as filled" do
    {_, milner} = Forge.saved_institution name: "Milner Ridge", rate: 22
    {_, stony} = Forge.saved_institution name: "Stony Mountain", rate: 33

    Forge.saved_request institution: stony, date: Ecto.Date.from_erl({2016, 12, 30}), start: Ecto.Time.from_erl({14, 30, 0})
    Forge.saved_request institution: milner, date: Ecto.Date.from_erl({2016, 12, 29}), start: Ecto.Time.from_erl({8, 30, 0})

    set_window_size current_window_handle, 1024, 768
    navigate_to "/"

    Top.ReportLink.click_

    NewReport
    |> fill_distance("25.5")
    |> fill_food("10.11")
    |> fill_notes("Ere I saw Elba")

    assert NewReport.Requests.get(0) |> NewReport.Requests.label == "8:30 AM on Thu, Dec 29 to Milner Ridge"
    assert NewReport.Requests.get(1) |> NewReport.Requests.label == "2:30 PM on Fri, Dec 30 to Stony Mountain"

    NewReport.Requests.get(1) |> NewReport.Requests.click_

    NewReport
    |> submit

    assert Top.info_alert == "Report created successfully."

    navigate_to "/reports"

    assert Top.error_alert == "You do not have the proper authorisation to do that"

    set_window_size current_window_handle, 1024, 768

    PrisonRideshare.IntegrationHelper.log_in_as_admin

    Top.RequestsLink.click_

    # FIXME replace with page object method
    assert has_class?({:css, "tbody tr:nth-child(1)"}, "complete")
    refute has_class?({:css, "tbody tr:nth-child(2)"}, "complete")

    Top.ReportsLink.click_

    report = Reports.Reports.get(0)
    assert Reports.Reports.distance(report) == "25.5"
    assert Reports.Reports.rate(report) == "0.33"
    assert Reports.Reports.food(report) == "10.11"
    assert Reports.Reports.notes(report) == "Ere I saw Elba"
  end
end
