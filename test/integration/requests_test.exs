defmodule PrisonRideshare.Integration.Requests do
  use PrisonRideshare.ConnCase

  use Hound.Helpers

  alias PrisonRideshare.Pages.NewRequest

  hound_session

  test "list requests" do
    Forge.saved_request contact: "5551212"

    navigate_to "/requests"

    assert visible_text({:css, "tbody tr td:nth-child(5)"}) == "5551212"
  end

  test "creating a request" do
    navigate_to "/requests/new"

    NewRequest.fill_start("11:30:00")
    NewRequest.fill_end("12:30:00")
    NewRequest.fill_address("91 Albert St.")
    NewRequest.fill_contact("5551313")
    NewRequest.fill_passengers("2")
    NewRequest.fill_notes("mandatory")

    NewRequest.submit

    assert visible_text({:css, "tbody tr td:nth-child(2)"}) == "11:30:00"
    assert visible_text({:css, "tbody tr td:nth-child(3)"}) == "12:30:00"
  end
end

defmodule PrisonRideshare.Pages.NewRequest do
  use Hound.Helpers

  def fill_start(time) do
    fill_field({:id, "request_start"}, time)
  end

  def fill_end(time) do
    fill_field({:id, "request_end"}, time)
  end

  def fill_address(address) do
    fill_field({:id, "request_address"}, address)
  end

  def fill_contact(contact) do
    fill_field({:id, "request_contact"}, contact)
  end

  def fill_passengers(passengers) do
    fill_field({:id, "request_passengers"}, passengers)
  end

  def fill_notes(notes) do
    fill_field({:id, "request_notes"}, notes)
  end

  def submit do
    click({:class, "btn"})
  end
end
