defmodule PrisonRideshareWeb.DebtController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.{Person, Reimbursement}

  plug(:scrub_params, "data" when action in [:create, :update])

  def index(conn, _params) do
    people =
      Ecto.Query.order_by(Person, :name)
      |> Repo.all()
      |> Repo.preload(drivings: ride_preloads(), car_uses: ride_preloads())

    debts =
      Enum.map(people, fn person ->
        rides_and_expenses = collect_rides_with_expenses(person)

        Map.merge(rides_and_expenses, %{
          id: person.id,
          person: person
        })
      end)
      |> Enum.reject(fn person_debt ->
        person_debt.food_expenses == Money.new(0) && person_debt.car_expenses == Money.new(0)
      end)

    render(conn, "index.json-api", data: debts)
  end

  def delete(conn, %{"id" => id}) do
    person =
      Repo.get!(Person, id) |> Repo.preload(drivings: ride_preloads(), car_uses: ride_preloads())

    rides_and_expenses = collect_rides_with_expenses(person)

    Enum.each(rides_and_expenses.rides, fn ride ->
      if ride.driver_id == person.id && ride.food_expenses.amount > 0 do
        food_expenses_without_reimbursements =
          Money.subtract(
            ride.food_expenses,
            total_reimbursement_attributes(ride.reimbursements, :food_expenses)
          )

        changeset =
          Reimbursement.changeset(%Reimbursement{}, %{
            person_id: person.id,
            ride_id: ride.id,
            food_expenses: food_expenses_without_reimbursements
          })

        PaperTrail.insert!(changeset, version_information(conn))
      end

      if ride.car_owner_id == person.id && ride.car_expenses.amount > 0 do
        car_expenses_without_reimbursements =
          Money.subtract(
            ride.car_expenses,
            total_reimbursement_attributes(ride.reimbursements, :car_expenses)
          )

        changeset =
          Reimbursement.changeset(%Reimbursement{}, %{
            person_id: person.id,
            ride_id: ride.id,
            car_expenses: car_expenses_without_reimbursements,
            donation: ride.donation
          })

        PaperTrail.insert!(changeset, version_information(conn))
      end
    end)

    send_resp(conn, :no_content, "")
  end

  defp collect_rides_with_expenses(person) do
    rides_to_car_expenses = total_ride_attributes(person.car_uses, :car_expenses)
    rides_to_food_expenses = total_ride_attributes(person.drivings, :food_expenses)

    rides_with_expenses =
      Enum.uniq_by(Map.keys(rides_to_car_expenses) ++ Map.keys(rides_to_food_expenses), fn ride ->
        ride.id
      end)

    %{
      food_expenses: sum_money(Map.values(rides_to_food_expenses)),
      car_expenses: sum_money(Map.values(rides_to_car_expenses)),
      rides: rides_with_expenses
    }
  end

  defp total_ride_attributes(rides, attribute) do
    Enum.map(rides, fn ride ->
      total =
        Money.subtract(
          Map.fetch!(ride, attribute),
          total_reimbursement_attributes(ride.reimbursements, attribute)
        )

      {ride, total}
    end)
    |> Enum.reject(fn {_, total} -> total == Money.new(0) end)
    |> Map.new()
  end

  defp total_reimbursement_attributes(reimbursements, attribute) do
    Enum.reduce(reimbursements, Money.new(0), fn reimbursement, sum ->
      Money.add(sum, Map.fetch!(reimbursement, attribute))
    end)
  end

  defp sum_money(values) do
    Enum.reduce(values, Money.new(0), fn value, sum -> Money.add(sum, value) end)
  end

  defp ride_preloads do
    [:car_owner, :driver, :children, :institution, reimbursements: [:person, :ride]]
  end
end
