Application.ensure_all_started(:hound)

ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(PrisonRideshare.Repo, :manual)

defmodule Forge do
  use Blacksmith

  @save_one_function &Blacksmith.Config.save/1
  @save_all_function &Blacksmith.Config.save_all/1

  register :report, %PrisonRideshare.Report{}
  register :request, %PrisonRideshare.Request{}
  register :institution, %PrisonRideshare.Institution{}

  register :person, %PrisonRideshare.Person{}
  register :user, %PrisonRideshare.User{}
end

defmodule PrisonRideshare.IntegrationHelper do
  use ExUnit.CaseTemplate
  use Hound.Helpers

  alias PrisonRideshare.Repo
  alias PrisonRideshare.User

  setup do
    # FIXME unable to create with Forge: Failed to update lockable attributes [password: {"can't be blank", []}]
    User.changeset(%User{}, %{name: "test", admin: true, email: "test@example.com", password: "test", password_confirmation: "test", confirmed_at: DateTime.utc_now})
    |> Repo.insert!

    # Forge.saved_user name: "test", email: "test@example.com", password: "test", password_confirmation: "test", confirmed_at: Ecto.DateTime.utc

    :ok
  end

  # FIXME how to get this callable without full namespace?
  def log_in_as_admin do
    navigate_to "/sessions/new"
    fill_field({:css, "#session_email"}, "test@example.com")
    fill_field({:css, "#session_password"}, "test")
    click({:css, "button[type=submit]"})
  end
end
