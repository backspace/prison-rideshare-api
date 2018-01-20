defmodule PrisonRideshareWeb.DebtView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes([:food_expenses, :car_expenses])

  money_amount(:food_expenses)
  money_amount(:car_expenses)

  has_one(
    :person,
    type: "person",
    include: true,
    serializer: PrisonRideshareWeb.PersonView
  )

  has_many(
    :rides,
    type: "ride",
    include: true,
    serializer: PrisonRideshareWeb.RideView
  )
end
