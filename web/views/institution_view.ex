defmodule PrisonRideshare.InstitutionView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :rate, :inserted_at, :updated_at]

  def rate(institution, _conn) do
    institution.rate.amount
  end
end
