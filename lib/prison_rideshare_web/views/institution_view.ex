defmodule PrisonRideshareWeb.InstitutionView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes([:name, :rate, :far, :inserted_at, :updated_at])

  money_amount(:rate)
end
