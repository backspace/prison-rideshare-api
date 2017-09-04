defmodule PrisonRideshareWeb.UserView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes [:email, :admin, :inserted_at, :updated_at]
  

end
