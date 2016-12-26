defmodule PrisonRideshare.Pages.Requests do
  use PageObject

  visitable :visit, "/requests"

  clickable :create, "main > a"

  collection :requests, item_scope: "tbody tr" do
    text :times, "td.times"

    text :name, "td.name"
    text :contact, "td.contact"

    text :institution, "td.institution"

    text :report_text, "td.report"
    attribute :report_href, "href", "td.report a"

    text :driver, "td.driver"
    text :car_owner, "td.car_owner"
  end
end
