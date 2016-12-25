defmodule PrisonRideshare.Plugs.Admin do
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller

  def init(default), do: default

  def call(%{assigns: %{current_user: nil}} = conn, _) do
    conn |> flash_and_redirect
  end

  def call(%{assigns: %{current_user: current_user}} = conn, _) do
    if current_user.admin do
      conn
    else
      conn
        |> flash_and_redirect
    end
  end

  def call(conn, _) do
    conn
      |> flash_and_redirect
  end

  defp flash_and_redirect(conn) do
    conn
      |> put_flash(:error, "You do not have the proper authorisation to do that")
      |> redirect(to: "/")
      |> halt
  end
end
