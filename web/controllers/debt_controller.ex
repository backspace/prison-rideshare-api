defmodule PrisonRideshare.DebtController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.Person
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, _params) do
    people = Repo.all(Person) |> Repo.preload([drivings: :reimbursements, car_uses: :reimbursements])

    debts = Enum.map(people, fn person ->
      rides_and_expenses = collect_rides_with_expenses(person)

      Map.merge(rides_and_expenses, %{
        id: person.id,
        person: person
      })
    end)
    |> Enum.reject(fn person_debt -> person_debt.food_expenses == Money.new(0) && person_debt.car_expenses == Money.new(0) end)

    render(conn, "index.json-api", data: debts)
  end

  defp collect_rides_with_expenses(person) do
    rides_to_car_expenses = total_ride_attributes(person.car_uses, :car_expenses)
    rides_to_food_expenses = total_ride_attributes(person.drivings, :food_expenses)

    rides_with_expenses = Enum.uniq(Map.keys(rides_to_car_expenses) ++ Map.keys(rides_to_food_expenses))

    %{
      food_expenses: sum_money(Map.values(rides_to_food_expenses)),
      car_expenses: sum_money(Map.values(rides_to_car_expenses)),
      rides: rides_with_expenses
    }
  end

  defp total_ride_attributes(rides, attribute) do
    Enum.map(rides, fn ride ->
      total = Money.subtract(Map.fetch!(ride, attribute), total_reimbursement_attributes(ride.reimbursements, attribute))

      {ride, total}
    end) |>
    Enum.reject(fn {ride, total} -> total == Money.new(0) end) |>
    Map.new
  end

  defp total_reimbursement_attributes(reimbursements, attribute) do
    Enum.reduce(reimbursements, Money.new(0), fn reimbursement, sum ->
      Money.add(sum, Map.fetch!(reimbursement, attribute))
    end)
  end

  defp sum_money(values) do
    Enum.reduce(values, Money.new(0), fn value, sum -> Money.add(sum, value) end)
  end
end
