defmodule PrisonRideshare.WhoDoneIt do
  def whodoneit(conn) do
    user = Guardian.Plug.current_resource(conn)
    [whodoneit: user, whodoneit_name: to_string(:inet_parse.ntoa(conn.remote_ip))]
  end
end
