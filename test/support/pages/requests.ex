defmodule PrisonRideshare.Pages.Requests do
  use PageObject

  visitable :visit, "/requests"

  clickable :create, "main > a"

  collection :requests, item_scope: "tbody tr" do
    text :times, "td:nth-child(2)"

    text :name, "td:nth-child(3)"
    text :contact, "td:nth-child(5)"

    text :institution, "td:nth-child(8)"

    text :report_text, "td:nth-child(9)"
    attribute :report_href, "href", "td:nth-child(9) a"

    text :driver, "td:nth-child(10)"
    text :car_owner, "td:nth-child(11)"
  end
end
