defmodule PrisonRideshare.ReimbursementView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:car_expenses, :food_expenses, :inserted_at, :updated_at]

  has_one :person,
    include: true,
    serializer: PrisonRideshare.PersonView

  money_amount :car_expenses
  money_amount :food_expenses
end
