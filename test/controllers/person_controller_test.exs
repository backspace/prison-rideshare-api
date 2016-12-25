defmodule PrisonRideshare.PersonControllerTest do
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.{Person, User}
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, person_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing people"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, person_path(conn, :new)
    assert html_response(conn, 200) =~ "New person"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, person_path(conn, :create), person: @valid_attrs
    assert redirected_to(conn) == person_path(conn, :index)
    assert Repo.get_by(Person, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, person_path(conn, :create), person: @invalid_attrs
    assert html_response(conn, 200) =~ "New person"
  end

  test "shows chosen resource", %{conn: conn} do
    person = Repo.insert! %Person{}
    conn = get conn, person_path(conn, :show, person)
    assert html_response(conn, 200) =~ "Show person"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, person_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    person = Repo.insert! %Person{}
    conn = get conn, person_path(conn, :edit, person)
    assert html_response(conn, 200) =~ "Edit person"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    person = Repo.insert! %Person{}
    conn = put conn, person_path(conn, :update, person), person: @valid_attrs
    assert redirected_to(conn) == person_path(conn, :show, person)
    assert Repo.get_by(Person, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    person = Repo.insert! %Person{}
    conn = put conn, person_path(conn, :update, person), person: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit person"
  end

  test "deletes chosen resource", %{conn: conn} do
    person = Repo.insert! %Person{}
    conn = delete conn, person_path(conn, :delete, person)
    assert redirected_to(conn) == person_path(conn, :index)
    refute Repo.get(Person, person.id)
  end
end
