defmodule PrisonRideshare.Pages.Requests do
  use PageObject

  visitable :visit, "/requests"

  clickable :create, "main > a"

  collection :requests, item_scope: "tbody tr" do
    text :start, "td:nth-child(2)"
    text :end, "td:nth-child(3)"
    text :contact, "td:nth-child(5)"

    text :institution, "td:nth-child(8)"
  end
end
