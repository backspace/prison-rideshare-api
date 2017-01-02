defmodule PrisonRideshare.ReimbursementView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:amount, :inserted_at, :updated_at]

  has_one :person,
    field: :person_id,
    type: "person"

  def amount(reimbursement, _conn) do
    reimbursement.amount.amount
  end
end
