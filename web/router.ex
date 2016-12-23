defmodule PrisonRideshare.Router do
  use PrisonRideshare.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PrisonRideshare do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/requests", RequestController
    resources "/institutions", InstitutionController
  end

  # Other scopes may use custom stacks.
  # scope "/api", PrisonRideshare do
  #   pipe_through :api
  # end
end
