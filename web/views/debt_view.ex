defmodule PrisonRideshare.DebtView do
  use PrisonRideshare.Web, :view
  use JaSerializer.PhoenixView

  attributes [:food_amount, :car_amount]

  money_amount :food_amount
  money_amount :car_amount

  has_one :person,
    type: "person"
end
