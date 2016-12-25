defmodule PrisonRideshare.Pages.Top do
  use PageObject

  text :error_alert, ".alert-danger"
  text :info_alert, ".alert-info"

  def requests_link do
    [:css, "a.requests"]
  end

  defmodule RequestsLink do
    clickable :click_, "a.requests"
  end

  defmodule ReportsLink do
    clickable :click_, "a.reports"
  end

  defmodule ReportLink do
    clickable :click_, "a.report"
  end

  def logout_link do
    [:css, "a.logout"]
  end
end
