defmodule PrisonRideshare.ReimbursementControllerTest do
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.Reimbursement
  alias PrisonRideshare.Repo

  @valid_attrs %{amount: 42}
  @invalid_attrs %{}

  setup do
    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  defp relationships do
    person = Repo.insert!(%PrisonRideshare.Person{})

    %{
      "person" => %{
        "data" => %{
          "type" => "person",
          "id" => person.id
        }
      },
    }
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, reimbursement_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    reimbursement = Repo.insert! %Reimbursement{amount: 1919}
    conn = get conn, reimbursement_path(conn, :show, reimbursement)
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{reimbursement.id}"
    assert data["type"] == "reimbursement"
    assert data["attributes"]["amount"] == reimbursement.amount
    assert data["attributes"]["person_id"] == reimbursement.person_id
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, reimbursement_path(conn, :show, "00000000-0000-0000-0000-000000000000")
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, reimbursement_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "reimbursement",
        "attributes" => @valid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Reimbursement, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, reimbursement_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "reimbursement",
        "attributes" => @invalid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    reimbursement = Repo.insert! %Reimbursement{}
    conn = put conn, reimbursement_path(conn, :update, reimbursement), %{
      "meta" => %{},
      "data" => %{
        "type" => "reimbursement",
        "id" => reimbursement.id,
        "attributes" => @valid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Reimbursement, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    reimbursement = Repo.insert! %Reimbursement{}
    conn = put conn, reimbursement_path(conn, :update, reimbursement), %{
      "meta" => %{},
      "data" => %{
        "type" => "reimbursement",
        "id" => reimbursement.id,
        "attributes" => @invalid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    reimbursement = Repo.insert! %Reimbursement{}
    conn = delete conn, reimbursement_path(conn, :delete, reimbursement)
    assert response(conn, 204)
    refute Repo.get(Reimbursement, reimbursement.id)
  end

end
