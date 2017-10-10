defmodule PrisonRideshareWeb.UserChannel do
  use PrisonRideshareWeb, :channel
  # use Guardian.Channel

  require Logger

  alias PrisonRideshareWeb.Presence

  def join("user:" <> _something, payload, socket) do
    if authorized?(payload) do
      send(self, :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list(socket)
    Logger.error "socket assigns:"
    Logger.error inspect(socket.assigns)
    {:ok, _} = Presence.track(socket, socket.assigns.guardian_default_claims["sub"], %{
      online_at: inspect(System.system_time(:seconds))
      })
    {:noreply, socket}
  end
end
