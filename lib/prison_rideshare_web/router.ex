defmodule PrisonRideshareWeb.Router do
  use PrisonRideshareWeb, :router

  pipeline :api do
    plug(:accepts, ["json", "json-api"])
    plug(PrisonRideshare.Guardian.AuthPipeline)
    plug(JaSerializer.Deserializer)
  end

  pipeline :calendar do
    plug(:accepts, ["ics", "ifb"])
  end

  pipeline :person_api do
    plug(:accepts, ["json", "json-api"])
    plug(PrisonRideshare.PersonGuardian.AuthPipeline)
    plug(PrisonRideshare.Guardian.AuthPipeline)
    plug(JaSerializer.Deserializer)
  end

  pipeline :authenticated_api do
    plug(:accepts, ["json", "json-api"])
    plug(PrisonRideshare.Guardian.EnsuredAuthPipeline)
    plug(PrisonRideshareWeb.Plugs.LastSeen)
    plug(JaSerializer.Deserializer)
  end

  pipeline :admin_api do
    plug(:accepts, ["json", "json-api"])
    plug(PrisonRideshare.Guardian.EnsuredAuthPipeline)
    plug(PrisonRideshareWeb.Plugs.Admin)
    plug(JaSerializer.Deserializer)
  end

  pipeline :admin_non_json_api do
    plug(PrisonRideshare.Guardian.EnsuredAuthPipeline)
    plug(PrisonRideshareWeb.Plugs.Admin)
  end

  pipeline :person_authenticated_api do
    plug(:accepts, ["json", "json-api"])
    plug(PrisonRideshare.PersonGuardian.EnsuredAuthPipeline)
    plug(JaSerializer.Deserializer)
  end

  scope "/", PrisonRideshareWeb do
    pipe_through(:admin_api)

    get("/rides/overlaps", RideController, :overlaps)
  end

  scope "/", PrisonRideshareWeb do
    pipe_through(:calendar)

    get("/rides/calendar", RideController, :calendar)
    get("/people/:id/calendar", PersonController, :calendar)
  end

  scope "/", PrisonRideshareWeb do
    pipe_through(:api)

    post("/register", RegistrationController, :create)
    post("/token", SessionController, :create, as: :login)

    post("/users/reset", UserController, :reset)

    resources("/gas-prices", GasPriceController, only: [:index])
    resources("/rides", RideController, except: [:new, :edit])
    resources("/slots", SlotController, only: [:index])
    resources("/users", UserController, only: [:update])
  end

  scope "/", PrisonRideshareWeb do
    pipe_through(:authenticated_api)

    get("/users/current", UserController, :current)
  end

  scope "/", PrisonRideshareWeb do
    pipe_through(:person_api)

    post("/people/token", PersonSessionController, :create, as: :person_login)

    get("/people/me", PersonSessionController, :show, as: :person_identify)
    patch("/people/me", PersonSessionController, :update, as: :person_patch)
  end

  scope "/", PrisonRideshareWeb do
    pipe_through(:admin_api)

    resources("/debts", DebtController, only: [:index, :delete])
    resources("/institutions", InstitutionController, except: [:new, :edit])
    resources("/people", PersonController, except: [:new, :edit])
    resources("/reimbursements", ReimbursementController, except: [:new, :edit])
    resources("/users", UserController, only: [:index, :show, :create, :delete])

    resources("/posts", PostController, except: [:new, :edit])
    post("/posts/readings", PostController, :read_all_posts)
    post("/posts/:id/readings", PostController, :read_post)
    delete("/posts/:id/readings", PostController, :unread_post)

    post("/rides/:id/ignore/:commitment_id", RideController, :ignore_commitment)
  end

  scope "/", PrisonRideshareWeb do
    pipe_through(:admin_non_json_api)

    post(
      "/people/:id/calendar-email/:month",
      PersonController,
      :email_calendar_link,
      as: :person_calendar_email
    )

    get(
      "/people/:id/calendar-link/:month",
      PersonController,
      :calendar_link,
      as: :person_calendar_link
    )
  end

  scope "/", PrisonRideshareWeb do
    pipe_through(:person_api)

    resources("/commitments", CommitmentController, only: [:show, :create, :delete])
  end

  if Mix.env() == :dev do
    forward("/sent_emails", Bamboo.SentEmailViewerPlug)
  end
end
