defmodule PrisonRideshare.VersionInformation do
  def version_information(conn) do
    user = Guardian.Plug.current_resource(conn)
    [originator: user, meta: %{ip: to_string(:inet_parse.ntoa(conn.remote_ip))}]
  end
end
