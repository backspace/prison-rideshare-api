defmodule PrisonRideshare.Pages.NewRequest do
  use PageObject

  fillable :fill_start_hour, "#request_start_hour", clear: false
  fillable :fill_start_minute, "#request_start_minute", clear: false
  fillable :fill_end_hour, "#request_end_hour", clear: false
  fillable :fill_end_minute, "#request_end_minute", clear: false
  fillable :fill_name, "#request_name"
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
