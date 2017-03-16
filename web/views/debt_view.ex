defmodule PrisonRideshare.DebtView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:food_expenses, :car_expenses]

  money_amount :food_expenses
  money_amount :car_expenses

  has_one :person,
    type: "person"
end
