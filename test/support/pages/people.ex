defmodule PrisonRideshare.Pages.People do
  use PageObject

  visitable :visit, "/people"

  collection :people, item_scope: "tbody tr" do
    text :name, ".name"
    text :food, ".food"
    text :car, ".car"
    text :reimbursements, ".reimbursements"
    text :owed, ".owed"
  end
end
