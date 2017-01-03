defmodule PrisonRideshare.ReimbursementView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:amount, :inserted_at, :updated_at]

  has_one :person,
    include: true,
    serializer: PrisonRideshare.PersonView

  money_amount :amount
end
