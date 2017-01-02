defmodule PrisonRideshare.PersonController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.Person

  def index(conn, _params) do
    people = Person.sorted(Person)
    |> Repo.all
    |> Repo.preload([{:car_uses, :report}, {:drivings, :report}, :reimbursements])

    people_owed = Enum.reduce(people, %{}, fn person, people_owed ->
      car_expenses = Enum.reduce(person.car_uses, Money.new(0), fn request, sum ->
        case request.report do
          nil -> sum
          report -> Money.add(Money.multiply(report.rate, report.distance), sum)
        end
      end)

      food_expenses = Enum.reduce(person.drivings, Money.new(0), fn request, sum ->
        case request.report do
          nil -> sum
          report -> Money.add(report.food_expenses, sum)
        end
      end)

      reimbursements = Enum.reduce(person.reimbursements, Money.new(0), fn reimbursement, sum ->
        Money.add(reimbursement.amount, sum)
      end)

      owed = Money.subtract(Money.add(car_expenses, food_expenses), reimbursements)

      Map.put(people_owed, person, %{
        owed: owed,
        car_expenses: car_expenses,
        food_expenses: food_expenses,
        reimbursements: reimbursements
      })
    end)
    render(conn, "index.html", people: people, people_owed: people_owed)
  end

  def new(conn, _params) do
    changeset = Person.changeset(%Person{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"person" => person_params}) do
    changeset = Person.changeset(%Person{}, person_params)

    case Repo.insert(changeset) do
      {:ok, _person} ->
        conn
        |> put_flash(:info, "Person created successfully.")
        |> redirect(to: person_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    person = Repo.get!(Person, id)
    render(conn, "show.html", person: person)
  end

  def edit(conn, %{"id" => id}) do
    person = Repo.get!(Person, id)
    changeset = Person.changeset(person)
    render(conn, "edit.html", person: person, changeset: changeset)
  end

  def update(conn, %{"id" => id, "person" => person_params}) do
    person = Repo.get!(Person, id)
    changeset = Person.changeset(person, person_params)

    case Repo.update(changeset) do
      {:ok, person} ->
        conn
        |> put_flash(:info, "Person updated successfully.")
        |> redirect(to: person_path(conn, :show, person))
      {:error, changeset} ->
        render(conn, "edit.html", person: person, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    person = Repo.get!(Person, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(person)

    conn
    |> put_flash(:info, "Person deleted successfully.")
    |> redirect(to: person_path(conn, :index))
  end
end
