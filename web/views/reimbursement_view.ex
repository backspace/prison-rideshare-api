defmodule PrisonRideshare.ReimbursementView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:amount, :inserted_at, :updated_at]

  has_one :person,
    field: :person_id,
    type: "person"

  money_amount :amount
end
