defmodule PrisonRideshare.RequestControllerTest do
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.Request
  @valid_attrs %{name: "some content", address: "some content", contact: "some content", date: %{day: 17, month: 4, year: 2010}, end: %{hour: 14, min: 0, sec: 0}, notes: "some content", passengers: 42, start: %{hour: 14, min: 0, sec: 0}}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, request_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing requests"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, request_path(conn, :new)
    assert html_response(conn, 200) =~ "New request"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, request_path(conn, :create), request: @valid_attrs
    assert redirected_to(conn) == request_path(conn, :index)
    assert Repo.get_by(Request, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, request_path(conn, :create), request: @invalid_attrs
    assert html_response(conn, 200) =~ "New request"
  end

  test "shows chosen resource", %{conn: conn} do
    request = Repo.insert! %Request{}
    conn = get conn, request_path(conn, :show, request)
    assert html_response(conn, 200) =~ "Show request"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, request_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    request = Repo.insert! %Request{}
    conn = get conn, request_path(conn, :edit, request)
    assert html_response(conn, 200) =~ "Edit request"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    request = Repo.insert! %Request{}
    conn = put conn, request_path(conn, :update, request), request: @valid_attrs
    assert redirected_to(conn) == request_path(conn, :show, request)
    assert Repo.get_by(Request, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    request = Repo.insert! %Request{}
    conn = put conn, request_path(conn, :update, request), request: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit request"
  end

  test "deletes chosen resource", %{conn: conn} do
    request = Repo.insert! %Request{}
    conn = delete conn, request_path(conn, :delete, request)
    assert redirected_to(conn) == request_path(conn, :index)
    refute Repo.get(Request, request.id)
  end
end
