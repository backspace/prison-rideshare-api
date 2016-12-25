defmodule PrisonRideshare.InstitutionControllerTest do
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.{Institution, User}
  @valid_attrs %{name: "some content", rate: "120.5"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1, admin: true}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, institution_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing institutions"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, institution_path(conn, :new)
    assert html_response(conn, 200) =~ "New institution"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, institution_path(conn, :create), institution: @valid_attrs
    assert redirected_to(conn) == institution_path(conn, :index)
    assert Repo.get_by(Institution, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, institution_path(conn, :create), institution: @invalid_attrs
    assert html_response(conn, 200) =~ "New institution"
  end

  test "shows chosen resource", %{conn: conn} do
    institution = Repo.insert! %Institution{}
    conn = get conn, institution_path(conn, :show, institution)
    assert html_response(conn, 200) =~ "Show institution"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, institution_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    institution = Repo.insert! %Institution{}
    conn = get conn, institution_path(conn, :edit, institution)
    assert html_response(conn, 200) =~ "Edit institution"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    institution = Repo.insert! %Institution{}
    conn = put conn, institution_path(conn, :update, institution), institution: @valid_attrs
    assert redirected_to(conn) == institution_path(conn, :show, institution)
    assert Repo.get_by(Institution, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    institution = Repo.insert! %Institution{}
    conn = put conn, institution_path(conn, :update, institution), institution: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit institution"
  end

  test "deletes chosen resource", %{conn: conn} do
    institution = Repo.insert! %Institution{}
    conn = delete conn, institution_path(conn, :delete, institution)
    assert redirected_to(conn) == institution_path(conn, :index)
    refute Repo.get(Institution, institution.id)
  end
end
