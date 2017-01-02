defmodule PrisonRideshare.ReimbursementView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:amount, :inserted_at, :updated_at]

  has_one :person,
    field: :person_id,
    type: "person"

  def amount(reimbursement, _conn) do
    amount_or_zero(reimbursement.amount)
  end

  # FIXME extract to shared?
  defp amount_or_zero(nil), do: 0
  defp amount_or_zero(%{amount: amount}), do: amount
end
