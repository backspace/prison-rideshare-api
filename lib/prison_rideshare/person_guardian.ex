defmodule PrisonRideshare.PersonGuardian do
  use Guardian, otp_app: :prison_rideshare
  use SansPassword

  alias PrisonRideshare.Repo
  alias PrisonRideshareWeb.Person

  def subject_for_token(person = %Person{}, _claims), do: { :ok, "Person:#{person.id}" }
  def subject_for_token(_), do: { :error, "Unknown resource type" }

  def resource_from_claims(%{"sub" => "Person:" <> id}), do: { :ok, Repo.get(Person, id) }
  def resource_from_claims(_), do: { :error, "Unknown resource type" }

  # This silences a warning; the delivery happens in Email
  def deliver_magic_link(_, _, _), do: {}
end
