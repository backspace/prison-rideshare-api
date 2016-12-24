defmodule PrisonRideshare.Pages.NewReport do
  use PageObject

  fillable :fill_distance, "#report_distance"
  fillable :fill_expenses, "#report_expenses"
  fillable :fill_notes, "#report_notes"

  clickable :submit, ".btn"
end
