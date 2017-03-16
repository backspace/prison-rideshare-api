defmodule PrisonRideshare.DebtController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.Person
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, _params) do
    people = Repo.all(Person) |> Repo.preload([drivings: :reimbursements, car_uses: :reimbursements])

    debts = Enum.map(people, fn person ->
      %{
        id: person.id,
        person: person,
        drivings: person.drivings,
        car_uses: person.car_uses,
        food_expenses: total_ride_attributes(person.drivings, :food_expenses),
        car_expenses: total_ride_attributes(person.car_uses, :car_expenses)
      }
    end)
    |> Enum.reject(fn person_debt -> person_debt.food_expenses == Money.new(0) && person_debt.car_expenses == Money.new(0) end)

    render(conn, "index.json-api", data: debts)
  end

  defp total_ride_attributes(rides, attribute) do
    Enum.reduce(rides, Money.new(0), fn ride, sum ->
      Money.subtract(Money.add(sum, Map.fetch!(ride, attribute)), total_reimbursement_attributes(ride.reimbursements, attribute))
    end)
  end

  defp total_reimbursement_attributes(reimbursements, attribute) do
    Enum.reduce(reimbursements, Money.new(0), fn reimbursement, sum ->
      Money.add(sum, Map.fetch!(reimbursement, attribute))
    end)
  end
end
