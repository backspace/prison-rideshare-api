defmodule PrisonRideshare.ReimbursementControllerTest do
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.{Reimbursement, User}
  @valid_attrs %{amount: 42}
  @invalid_attrs %{}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1, admin: true}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, reimbursement_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing reimbursements"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, reimbursement_path(conn, :new)
    assert html_response(conn, 200) =~ "New reimbursement"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, reimbursement_path(conn, :create), reimbursement: @valid_attrs
    assert redirected_to(conn) == reimbursement_path(conn, :index)
    assert Repo.get_by(Reimbursement, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, reimbursement_path(conn, :create), reimbursement: @invalid_attrs
    assert html_response(conn, 200) =~ "New reimbursement"
  end

  test "shows chosen resource", %{conn: conn} do
    reimbursement = Repo.insert! %Reimbursement{}
    conn = get conn, reimbursement_path(conn, :show, reimbursement)
    assert html_response(conn, 200) =~ "Show reimbursement"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, reimbursement_path(conn, :show, "00000000-0000-0000-0000-000000000000")
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    reimbursement = Repo.insert! %Reimbursement{}
    conn = get conn, reimbursement_path(conn, :edit, reimbursement)
    assert html_response(conn, 200) =~ "Edit reimbursement"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    reimbursement = Repo.insert! %Reimbursement{}
    conn = put conn, reimbursement_path(conn, :update, reimbursement), reimbursement: @valid_attrs
    assert redirected_to(conn) == reimbursement_path(conn, :show, reimbursement)
    assert Repo.get_by(Reimbursement, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    reimbursement = Repo.insert! %Reimbursement{}
    conn = put conn, reimbursement_path(conn, :update, reimbursement), reimbursement: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit reimbursement"
  end

  test "deletes chosen resource", %{conn: conn} do
    reimbursement = Repo.insert! %Reimbursement{}
    conn = delete conn, reimbursement_path(conn, :delete, reimbursement)
    assert redirected_to(conn) == reimbursement_path(conn, :index)
    refute Repo.get(Reimbursement, reimbursement.id)
  end
end
