defmodule PrisonRideshare.InstitutionView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :rate, :inserted_at, :updated_at]

  def rate(institution, _conn) do
    amount_or_zero(institution.rate)
  end

  # FIXME extract to shared?
  defp amount_or_zero(nil), do: 0
  defp amount_or_zero(%{amount: amount}), do: amount
end
