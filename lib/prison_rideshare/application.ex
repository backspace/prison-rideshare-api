defmodule PrisonRideshare.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: PrisonRideshare.PubSub},
      # Start the Ecto repository
      PrisonRideshare.Repo,
      # Start the endpoint when the application starts
      PrisonRideshareWeb.Endpoint,
      # Start your own worker by calling: PrisonRideshare.Worker.start_link(arg1, arg2, arg3)
      # worker(PrisonRideshare.Worker, [arg1, arg2, arg3]),
      PrisonRideshareWeb.Presence
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PrisonRideshare.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PrisonRideshareWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
