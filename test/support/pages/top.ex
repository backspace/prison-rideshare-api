defmodule PrisonRideshare.Pages.Top do
  use PageObject

  text :error_alert, ".alert-danger"

  def requests_link do
    [:css, "a.requests"]
  end

  defmodule RequestsLink do
    clickable :click_, "a.requests"
  end

  defmodule ReportLink do
    clickable :click_, "a.report"
  end

  def logout_link do
    [:css, "a.logout"]
  end
end
