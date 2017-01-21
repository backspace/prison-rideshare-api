defmodule PrisonRideshare.Router do
  use PrisonRideshare.Web, :router

  pipeline :api do
    plug :accepts, ["json", "json-api"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug JaSerializer.Deserializer
  end

  pipeline :authenticated_api do
    plug :accepts, ["json", "json-api"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated, handler: PrisonRideshare.AuthErrorHandler
    plug JaSerializer.Deserializer
  end

  pipeline :admin_api do
    plug :accepts, ["json", "json-api"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated, handler: PrisonRideshare.AuthErrorHandler
    plug PrisonRideshare.Plugs.Admin
    plug JaSerializer.Deserializer
  end

  scope "/", PrisonRideshare do
    pipe_through :api

    post "/register", RegistrationController, :create
    post "/token", SessionController, :create, as: :login

    resources "/rides", RideController, except: [:new, :edit]
  end

  scope "/", PrisonRideshare do
    pipe_through :authenticated_api

    get "/users/current", UserController, :current
  end

  scope "/", PrisonRideshare do
    pipe_through :admin_api

    resources "/institutions", InstitutionController, except: [:new, :edit]
    resources "/people", PersonController, except: [:new, :edit]
    resources "/reimbursements", ReimbursementController, except: [:new, :edit]
    resources "/users", UserController, expect: [:new, :edit]
  end
end
