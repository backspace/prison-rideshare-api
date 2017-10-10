defmodule PrisonRideshareWeb.UserChannel do
  use PrisonRideshareWeb, :channel

  alias PrisonRideshareWeb.Presence

  def join("user:presence", _, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list(socket)

    {:ok, _} = Presence.track(socket, socket.assigns.guardian_default_claims["sub"], %{
      online_at: inspect(System.system_time(:seconds))
      })
    {:noreply, socket}
  end
end
