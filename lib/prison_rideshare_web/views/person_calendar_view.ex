defmodule PrisonRideshareWeb.PersonCalendarView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes([:name, :email, :mobile, :landline, :medium, :active])

  def type(_, _), do: "person"
end
