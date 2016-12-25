defmodule PrisonRideshare.ReportControllerTest do
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.{Report, User}
  @valid_attrs %{distance: "120.5", expenses: "120.5", notes: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = login(conn)
    conn = get conn, report_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing reports"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, report_path(conn, :new)
    assert html_response(conn, 200) =~ "New report"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, report_path(conn, :create), report: @valid_attrs
    assert redirected_to(conn) == report_path(conn, :index)
    assert Repo.get_by(Report, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, report_path(conn, :create), report: @invalid_attrs
    assert html_response(conn, 200) =~ "New report"
  end

  test "shows chosen resource", %{conn: conn} do
    conn = login(conn)
    report = Repo.insert! %Report{}
    conn = get conn, report_path(conn, :show, report)
    assert html_response(conn, 200) =~ "Show report"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = login(conn)
    assert_error_sent 404, fn ->
      get conn, report_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    conn = login(conn)
    report = Repo.insert! %Report{}
    conn = get conn, report_path(conn, :edit, report)
    assert html_response(conn, 200) =~ "Edit report"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    conn = login(conn)
    report = Repo.insert! %Report{}
    conn = put conn, report_path(conn, :update, report), report: @valid_attrs
    assert redirected_to(conn) == report_path(conn, :show, report)
    assert Repo.get_by(Report, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    conn = login(conn)
    report = Repo.insert! %Report{}
    conn = put conn, report_path(conn, :update, report), report: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit report"
  end

  test "deletes chosen resource", %{conn: conn} do
    conn = login(conn)
    report = Repo.insert! %Report{}
    conn = delete conn, report_path(conn, :delete, report)
    assert redirected_to(conn) == report_path(conn, :index)
    refute Repo.get(Report, report.id)
  end

  defp login(conn) do
    user = %User{name: "test", email: "test@example.com", id: 1, admin: true}
    assign(conn, :current_user, user)
  end
end
