defmodule PrisonRideshare.Guardian.AuthPipeline do
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline,
    otp_app: :prison_rideshare,
    module: PrisonRideshare.Guardian,
    error_handler: PrisonRideshare.Guardian.AuthErrorHandler

  plug(Guardian.Plug.VerifySession, claims: @claims)
  plug(Guardian.Plug.VerifyHeader, claims: @claims, scheme: "Bearer")
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
