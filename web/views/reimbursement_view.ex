defmodule PrisonRideshare.ReimbursementView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:car_amount, :food_amount, :inserted_at, :updated_at]

  has_one :person,
    include: true,
    serializer: PrisonRideshare.PersonView

  money_amount :car_amount
  money_amount :food_amount
end
