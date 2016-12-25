defmodule PrisonRideshare.Integration.People do
  use PrisonRideshare.ConnCase
  use PrisonRideshare.IntegrationHelper

  use Hound.Helpers

  alias PrisonRideshare.Pages.People

  hound_session

  test "list people and what they are owed" do
    Forge.saved_person %{name: "Capheus"}
    {_, sun} = Forge.saved_person %{name: "Sun"}
    Forge.saved_person %{name: "Nomi"}
    Forge.saved_person %{name: "Kala"}
    Forge.saved_person %{name: "Riley"}
    Forge.saved_person %{name: "Wolfgang"}
    {_, lito} = Forge.saved_person %{name: "Lito"}
    Forge.saved_person %{name: "Will"}

    {_, leavenworth} = Forge.saved_institution name: "Fort Leavenworth", rate: 11
    {_, request} = Forge.saved_request institution: leavenworth, driver: sun, car_owner: lito
    Forge.saved_report request: request, rate: 11, distance: 111.0, food: 1919

    Forge.saved_reimbursement person: lito, amount: 789

    PrisonRideshare.IntegrationHelper.log_in_as_admin

    People.visit

    assert People.People.get(0) |> People.People.name == "Capheus"
    assert People.People.get(7) |> People.People.name == "Wolfgang"

    assert People.People.get(5) |> People.People.name == "Sun"
    assert People.People.get(5) |> People.People.owed == "19.19"

    assert People.People.get(2) |> People.People.name == "Lito"
    assert People.People.get(2) |> People.People.owed == "4.32"
  end
end
