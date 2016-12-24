defmodule PrisonRideshare.Pages.NewReport do
  use PageObject

  fillable :fill_distance, "#report_distance"
  fillable :fill_expenses, "#report_expenses"
  fillable :fill_notes, "#report_notes"

  collection :requests, item_scope: ".radio label" do
    text :label, "span"
    clickable :click_, "input"
  end

  clickable :submit, ".btn"
end
