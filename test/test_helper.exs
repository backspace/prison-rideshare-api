Application.ensure_all_started(:hound)

ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(PrisonRideshare.Repo, :manual)

defmodule Forge do
  use Blacksmith

  @save_one_function &Blacksmith.Config.save/1
  @save_all_function &Blacksmith.Config.save_all/1

  register :request, %PrisonRideshare.Request{}
  register :institution, %PrisonRideshare.Institution{}

  register :person, %PrisonRideshare.Person{}
  register :user, %PrisonRideshare.User{}
end
