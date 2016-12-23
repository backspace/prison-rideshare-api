defmodule PrisonRideshare.Integration.Requests do
  use PrisonRideshare.ConnCase

  use Hound.Helpers

  hound_session

  test "list requests" do
    Forge.saved_request contact: "5551212"

    navigate_to "/requests"

    assert visible_text({:css, "tbody tr td:nth-child(5)"}) == "5551212"
  end
end
