defmodule PrisonRideshareWeb.Plugs.Admin do
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller

  def init(default), do: default

  def call(%{private: %{guardian_default_resource: nil}} = conn, _) do
    conn |> flash_and_redirect
  end

  def call(%{private: %{guardian_default_resource: %{admin: true}}} = conn, _) do
    conn
  end

  def call(conn, _) do
    conn
      |> flash_and_redirect
  end

  defp flash_and_redirect(conn) do
    # FIXME obvsy, is this private guardian_default_resource thing even okay?
    conn
      # |> put_flash(:error, "You do not have the proper authorisation to do that")
      |> redirect(to: "/")
      |> halt
  end
end
