defmodule PrisonRideshare.Router do
  use PrisonRideshare.Web, :router

  pipeline :api do
    plug :accepts, ["json-api"]
  end

  scope "/", PrisonRideshare do
    pipe_through :api

    post "/register", RegistrationController, :create
    post "/token", SessionController, :create, as: :login

    resources "/institutions", InstitutionController, except: [:new, :edit]
    resources "/people", PersonController, except: [:new, :edit]
    resources "/reimbursements", ReimbursementController, except: [:new, :edit]
    resources "/rides", RideController, except: [:new, :edit]
  end
end
