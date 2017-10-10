defmodule PrisonRideshareWeb.Presence do
  use Phoenix.Presence, otp_app: :prison_rideshare,
                        pubsub_server: PrisonRideshare.PubSub
end
