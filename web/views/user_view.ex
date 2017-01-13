defmodule PrisonRideshare.UserView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:email, :admin, :inserted_at, :updated_at]
  

end
