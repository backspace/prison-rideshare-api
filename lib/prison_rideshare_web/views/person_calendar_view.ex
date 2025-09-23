defmodule PrisonRideshareWeb.PersonCalendarView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :name,
    :email,
    :mobile,
    :landline,
    :address,
    :medium,
    :active,
    :self_notes,
    :calendar_secret
  ])

  def type(_, _), do: "person"
end
