defmodule PrisonRideshare.Pages.Reports do
  use PageObject

  visitable :visit, "/reports"

  collection :reports, item_scope: "tbody tr" do
    text :distance, ".distance"
    text :food, ".food"
    text :notes, ".notes"
  end
end
