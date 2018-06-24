defmodule PrisonRideshareWeb.InstitutionControllerTest do
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshareWeb.Institution
  alias PrisonRideshare.Repo

  @valid_attrs %{name: "some content", rate: 42, far: true}
  @invalid_attrs %{}

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> auth_as_admin

    {:ok, conn: conn}
  end

  defp relationships do
    %{}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, institution_path(conn, :index))
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    institution = Repo.insert!(%Institution{rate: 33, far: true})
    conn = get(conn, institution_path(conn, :show, institution))
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{institution.id}"
    assert data["type"] == "institution"
    assert data["attributes"]["name"] == institution.name
    assert data["attributes"]["rate"] == institution.rate
    assert data["attributes"]["far"]
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn ->
      get(conn, institution_path(conn, :show, "00000000-0000-0000-0000-000000000000"))
    end)
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn =
      post(conn, institution_path(conn, :create), %{
        "meta" => %{},
        "data" => %{
          "type" => "institutions",
          "attributes" => @valid_attrs,
          "relationships" => relationships()
        }
      })

    institution = Repo.get_by(Institution, @valid_attrs)
    assert json_response(conn, 201)["data"]["id"] == institution.id
    assert json_response(conn, 201)["data"]["attributes"]["name"] == "some content"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn =
      post(conn, institution_path(conn, :create), %{
        "meta" => %{},
        "data" => %{
          "type" => "institutions",
          "attributes" => @invalid_attrs,
          "relationships" => relationships()
        }
      })

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    institution = Repo.insert!(%Institution{})

    conn =
      put(conn, institution_path(conn, :update, institution), %{
        "meta" => %{},
        "data" => %{
          "type" => "institutions",
          "id" => institution.id,
          "attributes" => @valid_attrs,
          "relationships" => relationships()
        }
      })

    institution = Repo.get_by(Institution, @valid_attrs)
    assert json_response(conn, 200)["data"]["id"] == institution.id
    assert json_response(conn, 200)["data"]["attributes"]["name"] == "some content"
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    institution = Repo.insert!(%Institution{})

    conn =
      put(conn, institution_path(conn, :update, institution), %{
        "meta" => %{},
        "data" => %{
          "type" => "institutions",
          "id" => institution.id,
          "attributes" => @invalid_attrs,
          "relationships" => relationships()
        }
      })

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    institution = Repo.insert!(%Institution{})
    conn = delete(conn, institution_path(conn, :delete, institution))
    assert response(conn, 204)
    refute Repo.get(Institution, institution.id)
  end
end
