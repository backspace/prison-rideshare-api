defmodule PrisonRideshare.ReportController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.{Report, Request}

  def index(conn, _params) do
    reports = Repo.all(Report)
    render(conn, "index.html", reports: reports)
  end

  def new(conn, _params) do
    changeset = Report.changeset(%Report{})
    requests = Repo.all(Request) |> Repo.preload(:institution)
    render(conn, "new.html", requests: requests, changeset: changeset)
  end

  def create(conn, %{"report" => report_params}) do
    changeset = Report.changeset(%Report{}, report_params)

    case Repo.insert(changeset) do
      {:ok, _report} ->
        conn
        |> put_flash(:info, "Report created successfully.")
        |> redirect(to: report_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", requests: Repo.all(Request) |> Repo.preload(:institution), changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    report = Repo.get!(Report, id)
    render(conn, "show.html", report: report)
  end

  def edit(conn, %{"id" => id}) do
    report = Repo.get!(Report, id)
    changeset = Report.changeset(report)
    render(conn, "edit.html", report: report, requests: Repo.all(Request) |> Repo.preload(:institution), changeset: changeset)
  end

  def update(conn, %{"id" => id, "report" => report_params}) do
    report = Repo.get!(Report, id)
    changeset = Report.changeset(report, report_params)

    case Repo.update(changeset) do
      {:ok, report} ->
        conn
        |> put_flash(:info, "Report updated successfully.")
        |> redirect(to: report_path(conn, :show, report))
      {:error, changeset} ->
        render(conn, "edit.html", report: report, requests: Repo.all(Request) |> Repo.preload(:institution), changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    report = Repo.get!(Report, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(report)

    conn
    |> put_flash(:info, "Report deleted successfully.")
    |> redirect(to: report_path(conn, :index))
  end
end
