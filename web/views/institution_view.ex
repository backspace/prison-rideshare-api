defmodule PrisonRideshare.InstitutionView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :rate, :inserted_at, :updated_at]

  money_amount :rate
end
