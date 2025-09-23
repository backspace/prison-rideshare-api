defmodule PrisonRideshareWeb.ReimbursementControllerTest do
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshareWeb.Reimbursement
  alias PrisonRideshare.Repo

  @valid_attrs %{car_expenses: 42, processed: true}

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> auth_as_admin

    {:ok, conn: conn}
  end

  defp relationships do
    person = Repo.insert!(%PrisonRideshareWeb.Person{})

    %{
      "person" => %{
        "data" => %{
          "type" => "person",
          "id" => person.id
        }
      }
    }
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, Routes.reimbursement_path(conn, :index))
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    reimbursement =
      Repo.insert!(%Reimbursement{car_expenses: 1919, donation: true, processed: true})

    conn = get(conn, Routes.reimbursement_path(conn, :show, reimbursement))
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{reimbursement.id}"
    assert data["type"] == "reimbursement"
    assert data["attributes"]["car-expenses"] == reimbursement.car_expenses
    assert data["attributes"]["person_id"] == reimbursement.person_id
    assert data["attributes"]["donation"]
    assert data["attributes"]["processed"]
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn ->
      get(conn, Routes.reimbursement_path(conn, :show, "00000000-0000-0000-0000-000000000000"))
    end)
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn =
      post(conn, Routes.reimbursement_path(conn, :create), %{
        "meta" => %{},
        "data" => %{
          "type" => "reimbursements",
          "attributes" => @valid_attrs,
          "relationships" => relationships()
        }
      })

    reimbursement = Repo.get_by(Reimbursement, @valid_attrs)
    assert json_response(conn, 201)["data"]["id"] == reimbursement.id
    assert json_response(conn, 201)["data"]["attributes"]["processed"] == true
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    reimbursement = Repo.insert!(%Reimbursement{processed: false})

    conn =
      put(conn, Routes.reimbursement_path(conn, :update, reimbursement), %{
        "meta" => %{},
        "data" => %{
          "type" => "reimbursements",
          "id" => reimbursement.id,
          "attributes" => @valid_attrs,
          "relationships" => relationships()
        }
      })

    reimbursement = Repo.get_by(Reimbursement, @valid_attrs)
    assert json_response(conn, 200)["data"]["id"] == reimbursement.id
    assert json_response(conn, 200)["data"]["attributes"]["processed"] == true
  end

  test "deletes chosen resource", %{conn: conn} do
    reimbursement = Repo.insert!(%Reimbursement{})
    conn = delete(conn, Routes.reimbursement_path(conn, :delete, reimbursement))
    assert response(conn, 204)
    refute Repo.get(Reimbursement, reimbursement.id)
  end
end
