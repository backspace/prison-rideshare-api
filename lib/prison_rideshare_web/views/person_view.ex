defmodule PrisonRideshareWeb.PersonView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :name,
    :email,
    :mobile,
    :landline,
    :notes,
    :self_notes,
    :medium,
    :active,
    :inserted_at,
    :updated_at
  ])
end
