defmodule PrisonRideshare.Router do
  use PrisonRideshare.Web, :router

  pipeline :api do
    plug :accepts, ["json-api"]
  end

  pipeline :protected_api do
    plug :accepts, ["json", "json-api"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated, handler: PrisonRideshare.AuthErrorHandler
  end

  scope "/", PrisonRideshare do
    pipe_through :api

    post "/register", RegistrationController, :create
    post "/token", SessionController, :create, as: :login

  end

  scope "/", PrisonRideshare do
    pipe_through :protected_api

    resources "/institutions", InstitutionController, except: [:new, :edit]
    resources "/people", PersonController, except: [:new, :edit]
    resources "/reimbursements", ReimbursementController, except: [:new, :edit]
    resources "/rides", RideController, except: [:new, :edit]
  end
end
