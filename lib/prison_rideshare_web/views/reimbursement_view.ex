defmodule PrisonRideshareWeb.ReimbursementView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes([:car_expenses, :food_expenses, :donation, :processed, :inserted_at, :updated_at])

  has_one(
    :person,
    include: true,
    serializer: PrisonRideshareWeb.PersonView
  )

  has_one(:ride, type: "ride", identifiers: :always)

  money_amount(:car_expenses)
  money_amount(:food_expenses)
end
