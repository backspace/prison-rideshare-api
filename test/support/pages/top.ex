defmodule PrisonRideshare.Pages.Top do
  use PageObject

  def requests_link do
    [:css, "a.requests"]
  end

  def logout_link do
    [:css, "a.logout"]
  end
end
