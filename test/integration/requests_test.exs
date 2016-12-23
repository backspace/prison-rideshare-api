defmodule PrisonRideshare.Integration.Requests do
  use PrisonRideshare.ConnCase

  use Hound.Helpers

  alias PrisonRideshare.Pages.NewRequest
  import NewRequest

  hound_session

  test "list requests" do
    Forge.saved_request contact: "5551212"

    navigate_to "/requests"

    assert visible_text({:css, "tbody tr td:nth-child(5)"}) == "5551212"
  end

  test "creating a request" do
    NewRequest.visit

    NewRequest
    |> fill_start("11:30:00")
    |> fill_end("12:30:00")
    |> fill_address("91 Albert St.")
    |> fill_contact("5551313")
    |> fill_passengers("2")
    |> submit

    assert visible_text({:css, "tbody tr td:nth-child(2)"}) == "11:30:00"
    assert visible_text({:css, "tbody tr td:nth-child(3)"}) == "12:30:00"
  end
end
