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

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (user:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
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
