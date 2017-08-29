defmodule PrisonRideshare.VersionInformation do
  def version_information(conn) do
    [meta: %{ip: to_string(:inet_parse.ntoa(conn.remote_ip))}]
  end
end
