defmodule PrisonRideshareWeb.InstitutionView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes([:name, :far, :inserted_at, :updated_at])
end
