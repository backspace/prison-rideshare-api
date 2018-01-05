defmodule PrisonRideshare.PersonGuardian.EnsuredAuthPipeline do
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline, otp_app: :prison_rideshare,
                              module: PrisonRideshare.PersonGuardian,
                              error_handler: PrisonRideshare.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifySession, claims: @claims
  plug Guardian.Plug.VerifyHeader, claims: @claims, realm: "Person Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, ensure: true
end
