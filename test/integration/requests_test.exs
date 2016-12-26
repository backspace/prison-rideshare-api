defmodule PrisonRideshare.Integration.Requests do
  use PrisonRideshare.ConnCase
  use PrisonRideshare.IntegrationHelper

  use Hound.Helpers

  alias PrisonRideshare.Pages.NewRequest
  import NewRequest

  alias PrisonRideshare.Pages.Top

  alias PrisonRideshare.Pages.Requests

  hound_session

  test "list requests and create one" do
    {_, milner} = Forge.saved_institution name: "Milner Ridge"
    Forge.saved_institution name: "Stony Mountain"

    {_, bhagat} = Forge.saved_person name: "Bhagat Singh"
    {_, john} = Forge.saved_person name: "John Wojtowicz"

    {_, report} = Forge.saved_report food: 1919, rate: 33, notes: "Schnimbleby Tortonhortons"

    future_date = Timex.to_erl(Timex.to_date(Timex.add(Timex.now, Timex.Duration.from_days(3))))
    Forge.saved_request name: "Francine", contact: "5551212", institution: milner, driver: bhagat, car_owner: john, report: report, date: Ecto.Date.from_erl(future_date)

    set_window_size current_window_handle, 1024, 768

    PrisonRideshare.IntegrationHelper.log_in_as_admin

    Top.RequestsLink.click_

    request = Requests.Requests.get(0)
    assert Requests.Requests.name(request) == "Francine"
    assert Requests.Requests.contact(request) == "5551212"
    assert Requests.Requests.report_text(request) == "Report"
    assert String.ends_with?(Requests.Requests.report_href(request), "/reports/#{report.id}")
    assert Requests.Requests.institution(request) == "Milner Ridge"
    assert Requests.Requests.driver(request) == "Bhagat Singh"
    assert Requests.Requests.car_owner(request) == "John Wojtowicz"

    report = Requests.Reports.get(0)
    assert Requests.Reports.food(report) == "19.19"
    assert Requests.Reports.notes(report) == "Schnimbleby Tortonhortons"
    assert Requests.Reports.rate(report) == "0.33"

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
    |> fill_driver("John Wojtowicz")
    |> fill_car_owner("Bhagat Singh")

    NewRequest.Institutions.get(1)
    |> NewRequest.Institutions.click_

    NewRequest.submit

    new_request = Requests.Requests.get(0)
    assert Requests.Requests.times(new_request) == "11:30 AM — 12:30"
    assert Requests.Requests.name(new_request) == "Pascal"
    assert Requests.Requests.institution(new_request) == "Stony Mountain"
    assert Requests.Requests.report_text(new_request) == ""
    assert Requests.Requests.driver(new_request) == "John Wojtowicz"
    assert Requests.Requests.car_owner(new_request) == "Bhagat Singh"
  end
end
