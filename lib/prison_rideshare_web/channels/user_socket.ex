defmodule PrisonRideshareWeb.UserSocket do
  use Phoenix.Socket

  def connect(%{"guardian_token" => token}, socket) do
    case Guardian.Phoenix.Socket.authenticate(socket, PrisonRideshare.Guardian, token) do
      {:ok, authed_socket} ->
        {:ok, authed_socket}
      {:error, _} -> :error
    end
  end

  # This function will be called when there was no authentication information
  def connect(_params, _socket) do
    :error
  end

  ## Channels
  channel "user:*", PrisonRideshareWeb.UserChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     PrisonRideshareWeb.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
