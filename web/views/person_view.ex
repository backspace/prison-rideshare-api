defmodule PrisonRideshare.PersonView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :inserted_at, :updated_at]
  

end
