defmodule PrisonRideshareWeb.PersonView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes [:name, :inserted_at, :updated_at]
  

end
