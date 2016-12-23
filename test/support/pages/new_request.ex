defmodule PrisonRideshare.Pages.NewRequest do
  use PageObject

  fillable :fill_start, "#request_start"
  fillable :fill_end, "#request_end"
  fillable :fill_address, "#request_address"
  fillable :fill_contact, "#request_contact"
  fillable :fill_passengers, "#request_passengers"
  fillable :fill_notes, "#request_notes"

  collection :institutions, item_scope: ".radio label" do
    # FIXME without _: imported Hound.Helpers.Element.click/1 conflicts with local function
    clickable :click_, "input"
  end

  clickable :submit, ".btn"
end
