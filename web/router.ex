defmodule PrisonRideshare.Router do
  use PrisonRideshare.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser
  end

  scope "/" do
    pipe_through :protected
  end

  scope "/", PrisonRideshare do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    resources "/reports", ReportController
  end

  scope "/", PrisonRideshare do
    pipe_through :admin

    resources "/institutions", InstitutionController
    resources "/people", PersonController
    resources "/reimbursements", ReimbursementController
    resources "/rides", RideController
  end

  # Other scopes may use custom stacks.
  # scope "/api", PrisonRideshare do
  #   pipe_through :api
  # end
end
