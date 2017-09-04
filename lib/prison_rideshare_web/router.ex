defmodule PrisonRideshareWeb.Router do
  use PrisonRideshareWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

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
    plug Guardian.Plug.EnsureAuthenticated, handler: PrisonRideshareWeb.AuthErrorHandler
    plug JaSerializer.Deserializer
  end

  pipeline :admin_api do
    plug :accepts, ["json", "json-api"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated, handler: PrisonRideshareWeb.AuthErrorHandler
    plug PrisonRideshareWeb.Plugs.Admin
    plug JaSerializer.Deserializer
  end

  scope "/", PrisonRideshareWeb do
    pipe_through :api

    post "/register", RegistrationController, :create
    post "/token", SessionController, :create, as: :login

    resources "/rides", RideController, except: [:new, :edit]
  end

  scope "/", PrisonRideshareWeb do
    pipe_through :authenticated_api

    get "/users/current", UserController, :current
  end

  scope "/", PrisonRideshareWeb do
    pipe_through :admin_api

    resources "/debts", DebtController, only: [:index, :delete]
    resources "/institutions", InstitutionController, except: [:new, :edit]
    resources "/people", PersonController, except: [:new, :edit]
    resources "/reimbursements", ReimbursementController, except: [:new, :edit]
    resources "/users", UserController, expect: [:new, :edit]
  end
end
