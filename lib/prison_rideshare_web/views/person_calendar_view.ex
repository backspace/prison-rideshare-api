defmodule PrisonRideshareWeb.PersonCalendarView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes([:name, :email, :mobile, :landline, :medium, :active, :self_notes, :calendar_secret])

  def type(_, _), do: "person"
end
