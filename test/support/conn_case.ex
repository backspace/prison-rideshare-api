defmodule PrisonRideshareWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest

      alias PrisonRideshare.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias PrisonRideshareWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint PrisonRideshareWeb.Endpoint

      defp auth_as_admin(conn) do
        user =
          Repo.insert!(%PrisonRideshareWeb.User{
            email: "test@example.com",
            admin: true,
            id: Ecto.UUID.generate()
          })

        {:ok, jwt, _} = PrisonRideshare.Guardian.encode_and_sign(user)

        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
      end

      defp auth_as_person(conn, person \\ nil) do
        person =
          case person do
            nil ->
              Repo.insert!(%PrisonRideshareWeb.Person{
                email: "person@example.com",
                id: Ecto.UUID.generate()
              })

            _ ->
              person
          end

        {:ok, jwt, _} = PrisonRideshare.PersonGuardian.encode_and_sign(person)

        conn
        |> put_req_header("authorization", "Person Bearer #{jwt}")
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(PrisonRideshare.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(PrisonRideshare.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
