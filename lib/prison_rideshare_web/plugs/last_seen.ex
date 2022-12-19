defmodule PrisonRideshareWeb.Plugs.LastSeen do
  alias PrisonRideshare.Repo
  import Ecto.Query
  require Logger

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    user = Guardian.Plug.current_resource(conn)

    cond do
      user ->
        persist_last_seen(user)
        conn

      true ->
        conn
    end
  end

  defp persist_last_seen(user) do
    q = from(u in PrisonRideshareWeb.User, where: u.id == ^user.id)

    Repo.update_all(q, set: [last_seen_at: NaiveDateTime.utc_now()])
  end
end
