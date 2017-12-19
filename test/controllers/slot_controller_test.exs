defmodule PrisonRideshareWeb.SlotControllerTest do
  use PrisonRideshareWeb.ConnCase
  use Bamboo.Test

  alias PrisonRideshareWeb.{Commitment, Person, Slot}
  alias PrisonRideshare.Repo

  setup do
    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "lists all slots and their commitments", %{conn: conn} do
    [later, earlier, _, commitment] = create_data()

    conn = get conn, slot_path(conn, :index)
    assert json_response(conn, 200)["data"] == [%{
      "id" => later.id,
      "type" => "slot",
      "attributes" => %{
        "start" => "2017-12-10T13:00:00.000000Z",
        "end" => "2017-12-10T17:00:00.000000Z"
      },
      "relationships" => %{
          "commitments" => %{"data" => []}
      }},
      %{
        "id" => earlier.id,
        "type" => "slot",
        "attributes" => %{
          "start" => "2017-12-08T13:00:00.000000Z",
          "end" => "2017-12-08T17:00:00.000000Z"
        },
        "relationships" => %{
          "commitments" => %{
            "data" => [%{
              "type" => "commitment",
              "id" => commitment.id
            }]
          }
        }
    }]
  end

  test "can create a commitment", %{conn: conn} do
    [later, _, person, _] = create_data()

    conn = conn
    |> auth_as_person(person)
    |> post(commitment_path(conn, :create), %{
      "data" => %{
        "type" => "commitments",
        "attributes" => %{},
        "relationships" => %{
          "person" => %{
            "data" => %{
              "type" => "person",
              "id" => person.id
            }
          },
          "slot" => %{
            "data" => %{
              "type" => "slot",
              "id" => later.id
            }
          }
        }
      }
    })

    [_, commitment] = Repo.all(Commitment)

    assert json_response(conn, 201)["data"]["id"] == commitment.id
    assert commitment.person_id == person.id
    assert commitment.slot_id == later.id

    [version] = Repo.all PaperTrail.Version
    assert version.event == "insert"
    assert version.item_changes["slot_id"] == later.id
    assert version.item_changes["person_id"] == person.id
    assert version.meta["person"] == person.id
  end

  test "creating a commitment without a person token fails", %{conn: conn} do
    [_, earlier, person, _] = create_data()

    conn = post conn, commitment_path(conn, :create), %{
      "data" => %{
        "type" => "commitments",
        "attributes" => %{},
        "relationships" => %{
          "person" => %{
            "data" => %{
              "type" => "person",
              "id" => person.id
            }
          },
          "slot" => %{
            "data" => %{
              "type" => "slot",
              "id" => earlier.id
            }
          }
        }
      }
    }

    assert json_response(conn, 401) == %{
      "jsonapi" => %{"version" => "1.0"},
      "errors" => [%{"title" => "Unauthorized", "code" => 401}]
    }
  end

  test "creating a commitment for a different person fails", %{conn: conn} do
    [_, earlier, person, _] = create_data()

    conn = conn
    |> auth_as_person()
    |> post(commitment_path(conn, :create), %{
      "data" => %{
        "type" => "commitments",
        "attributes" => %{},
        "relationships" => %{
          "person" => %{
            "data" => %{
              "type" => "person",
              "id" => person.id
            }
          },
          "slot" => %{
            "data" => %{
              "type" => "slot",
              "id" => earlier.id
            }
          }
        }
      }
    })

    assert json_response(conn, 401) == %{
      "jsonapi" => %{"version" => "1.0"},
      "errors" => [%{"title" => "Unauthorized", "code" => 401}]
    }
  end

  test "creating a commitment on a slot that's full fails", %{conn: conn} do
    [_, earlier, person, _] = create_data()

    earlier = Ecto.Changeset.change(earlier, count: 1)
    |> Repo.update!

    conn = conn
    |> auth_as_person(person)
    |> post(commitment_path(conn, :create), %{
      "data" => %{
        "type" => "commitments",
        "attributes" => %{},
        "relationships" => %{
          "person" => %{
            "data" => %{
              "type" => "person",
              "id" => person.id
            }
          },
          "slot" => %{
            "data" => %{
              "type" => "slot",
              "id" => earlier.id
            }
          }
        }
      }
    })

    assert json_response(conn, 422)["errors"] == [
      %{
        "detail" => "Slot has its maximum number of commitments",
        "source" => %{"pointer" => "/data/relationships/slot"},
        "title" => "is full"
      }
    ]
  end

  test "can delete a commitment", %{conn: conn} do
    [_, earlier, person, commitment] = create_data()

    conn = conn
    |> auth_as_person(person)
    |> delete(commitment_path(conn, :delete, commitment))

    assert response(conn, 204)

    new_earlier = Repo.get!(Slot, earlier.id)
    |> Repo.preload(:commitments)

    assert length(new_earlier.commitments) == 0
  end

  defp create_data do
    later = Repo.insert! %Slot{
      start: Ecto.DateTime.from_erl({{2017, 12, 10}, {13, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 12, 10}, {17, 0, 0}})
    }

    earlier = Repo.insert! %Slot{
      start: Ecto.DateTime.from_erl({{2017, 12, 8}, {13, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 12, 8}, {17, 0, 0}})
    }

    person = Repo.insert! %Person{
      name: "Person"
    }

    commitment = Repo.insert! %Commitment{
      slot_id: earlier.id,
      person_id: person.id
    }

    [later, earlier, person, commitment]
  end
end
