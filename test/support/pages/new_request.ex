defmodule PrisonRideshare.Pages.NewRequest do
  use PageObject

  visitable :visit, "/requests/new"

  fillable :fill_start, "#request_start"
  fillable :fill_end, "#request_end"
  fillable :fill_address, "#request_address"
  fillable :fill_contact, "#request_contact"
  fillable :fill_passengers, "#request_passengers"
  fillable :fill_notes, "#request_notes"

  clickable :submit, ".btn"
end
