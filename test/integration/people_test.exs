defmodule PrisonRideshare.Integration.People do
  use PrisonRideshare.ConnCase
  use PrisonRideshare.IntegrationHelper

  use Hound.Helpers

  alias PrisonRideshare.Pages.People

  hound_session

  test "list people" do
    Forge.saved_person %{name: "Capheus"}
    Forge.saved_person %{name: "Sun"}
    Forge.saved_person %{name: "Nomi"}
    Forge.saved_person %{name: "Kala"}
    Forge.saved_person %{name: "Riley"}
    Forge.saved_person %{name: "Wolfgang"}
    Forge.saved_person %{name: "Lito"}
    Forge.saved_person %{name: "Will"}

    PrisonRideshare.IntegrationHelper.log_in_as_admin

    People.visit

    assert People.People.get(0) |> People.People.name == "Capheus"
    assert People.People.get(7) |> People.People.name == "Wolfgang"
  end
end
