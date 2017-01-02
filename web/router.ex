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
    plug :accepts, ["json-api"]
  end

  scope "/" do
    pipe_through :browser
  end

  scope "/" do
    pipe_through :protected
  end

  scope "/", PrisonRideshare do
    pipe_through :api

    resources "/institutions", InstitutionController, except: [:new, :edit]
    resources "/people", PersonController, except: [:new, :edit]
    resources "/reimbursements", ReimbursementController, except: [:new, :edit]
  end

  # Other scopes may use custom stacks.
  # scope "/api", PrisonRideshare do
  #   pipe_through :api
  # end
end
