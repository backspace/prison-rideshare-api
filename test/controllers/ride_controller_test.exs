defmodule PrisonRideshare.RideControllerTest do
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.{Ride, User}
  @valid_attrs %{name: "some content", address: "some content", contact: "some content", date: %{day: 17, month: 4, year: 2010}, end: %{hour: 14, min: 0, sec: 0}, request_notes: "some content", passengers: 42, start: %{hour: 14, min: 0, sec: 0}}
  @invalid_attrs %{}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1, admin: true}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, ride_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing rides"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, ride_path(conn, :new)
    assert html_response(conn, 200) =~ "New ride"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, ride_path(conn, :create), ride: @valid_attrs
    assert redirected_to(conn) == ride_path(conn, :index)
    assert Repo.get_by(Ride, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, ride_path(conn, :create), ride: @invalid_attrs
    assert html_response(conn, 200) =~ "New ride"
  end

  test "shows chosen resource", %{conn: conn} do
    ride = Repo.insert! %Ride{}
    conn = get conn, ride_path(conn, :show, ride)
    assert html_response(conn, 200) =~ "Show ride"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, ride_path(conn, :show, "00000000-0000-0000-0000-000000000000")
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    ride = Repo.insert! %Ride{}
    conn = get conn, ride_path(conn, :edit, ride)
    assert html_response(conn, 200) =~ "Edit ride"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    ride = Repo.insert! %Ride{}
    conn = put conn, ride_path(conn, :update, ride), ride: @valid_attrs
    assert redirected_to(conn) == ride_path(conn, :show, ride)
    assert Repo.get_by(Ride, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    ride = Repo.insert! %Ride{}
    conn = put conn, ride_path(conn, :update, ride), ride: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit ride"
  end

  test "deletes chosen resource", %{conn: conn} do
    ride = Repo.insert! %Ride{}
    conn = delete conn, ride_path(conn, :delete, ride)
    assert redirected_to(conn) == ride_path(conn, :index)
    refute Repo.get(Ride, ride.id)
  end
end
