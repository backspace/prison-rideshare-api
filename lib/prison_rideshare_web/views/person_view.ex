defmodule PrisonRideshareWeb.PersonView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  def type(_, _), do: "people"

  attributes([
    :name,
    :email,
    :mobile,
    :landline,
    :address,
    :notes,
    :self_notes,
    :medium,
    :active,
    :inserted_at,
    :updated_at
  ])
end
