defmodule PrisonRideshare.VersionInformation do
  def version_information(conn) do
    resource = Guardian.Plug.current_resource(conn)

    user =
      case resource do
        %PrisonRideshareWeb.User{} -> resource
        _ -> nil
      end

    # This is taken from https://github.com/tuvistavie/elixir-browser/blob/0c6708498336cbe5cb4b5a6b8c997af84b44d426/lib/browser.ex#L16
    agent =
      conn
      |> Plug.Conn.get_req_header("user-agent")
      |> case do
        [] -> nil
        [h | _t] -> h
      end

    meta = %{
      ip: to_string(:inet_parse.ntoa(conn.remote_ip)),
      "user-agent": agent
    }

    meta =
      case resource do
        %PrisonRideshareWeb.Person{} -> Map.put(meta, :person, resource.id)
        _ -> meta
      end

    [originator: user, meta: meta]
  end
end
