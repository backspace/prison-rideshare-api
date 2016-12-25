defmodule PrisonRideshare.Pages.People do
  use PageObject

  visitable :visit, "/people"

  collection :people, item_scope: "tbody tr" do
    text :name, ".name"
    text :owed, ".owed"
  end
end
