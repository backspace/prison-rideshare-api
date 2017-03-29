alias PrisonRideshare.Repo
alias PrisonRideshare.{Institution, Person, Reimbursement, Ride, User}

import Money.Sigils

Faker.start

user = User.changeset(%User{}, %{
  name: "Sandbox",
  email: "jorts@jants.ca",
  password: "password",
  password_confirmation: "password",
  confirmed_at: Ecto.DateTime.utc
})
|> Repo.insert!

User.admin_changeset(user, %{admin: true})
|> Repo.update!

headingley = Repo.insert! Institution.changeset(%Institution{name: "Headingley", rate: ~M[35]})
milner_ridge = Repo.insert! Institution.changeset(%Institution{name: "Milner Ridge", rate: ~M[25]})


defmodule Lol do
  def createRide(params) do
    today = Timex.beginning_of_day(Timex.local)

    merged = Map.merge(params, %{
      start: Ecto.DateTime.cast!(Timex.shift(today, params.relative_start)),
      end: Ecto.DateTime.cast!(Timex.shift(Timex.shift(today, params.relative_start), params.relative_end)),
      address: Faker.Address.street_address,
      contact: Faker.Phone.EnUs.phone,
      name: Faker.Name.first_name,
      institution_id: params.institution.id
    })

    merged = case Map.has_key?(merged, :driver) do
      true -> Map.merge(merged, %{driver_id: params.driver.id})
      false -> merged
    end

    merged = case Map.has_key?(merged, :car_owner) do
      true -> Map.merge(merged, %{car_owner_id: params.car_owner.id})
      false -> merged
    end

    Repo.insert! Ride.changeset(%Ride{}, merged)
  end

  def createPerson(name) do
    Repo.insert! Person.changeset(%Person{name: name})
  end
end

curtis = Lol.createPerson("Curtis")
sara = Lol.createPerson("Sara Ahmed")
chelsea = Lol.createPerson("Chelsea Manning")

tomorrowRide = Lol.createRide(%{
  relative_start: [days: 1, hours: 13, minutes: 30],
  relative_end: [hours: 1, minutes: 30],
  institution: headingley,
  driver: curtis,
  car_owner: sara
})

nextWeekRide = Lol.createRide(%{
  relative_start: [days: 7, hours: 15],
  relative_end: [hours: 3],
  institution: milner_ridge
})

similarRide = Lol.createRide(%{
  relative_start: [days: 7, hours: 15, minutes: 15],
  relative_end: [hours: 3, minutes: 30],
  institution: milner_ridge
})

Lol.createRide(%{
  relative_start: [days: 7, hours: 15],
  relative_end: [hours: 3, minutes: 15],
  institution: milner_ridge,
  combined_with_ride_id: nextWeekRide.id
})

lastWeekRide = Lol.createRide(%{
  relative_start: [days: -7, hours: 12],
  relative_end: [hours: 2],
  institution: headingley,
  distance: 25,
  food_expenses: ~M[1200],
  car_expenses: ~M[875],
  request_notes: "Some request notes",
  report_notes: "It happened! These are my notes.",
  driver: chelsea,
  car_owner: chelsea
})

lastMonthRide = Lol.createRide(%{
  relative_start: [days: -30, hours: 8],
  relative_end: [hours: 4],
  institution: milner_ridge,
  distance: 150,
  food_expenses: ~M[1414],
  car_expenses: ~M[3750],
  driver: sara,
  car_owner: sara
})

Repo.insert! %Reimbursement{
  ride: lastMonthRide,
  person: sara,
  food_expenses: ~M[1414]
}

Repo.insert! %Reimbursement{
  ride: lastMonthRide,
  person: sara,
  car_expenses: ~M[100]
}

cancelledRide = Lol.createRide(%{
  relative_start: [days: -11, hours: 9],
  relative_end: [hours: 2],
  institution: milner_ridge,
  enabled: false,
  cancellation_reason: "visitor"
})

yesterdayRide = Lol.createRide(%{
  relative_start: [days: -1, hours: 11],
  relative_end: [hours: 1, minutes: 45],
  institution: headingley,
  driver: chelsea,
  car_owner: chelsea
})

reimbursedRide = Lol.createRide(%{
  relative_start: [days: -45, hours: 9],
  relative_end: [hours: 2, minutes: 30],
  institution: headingley,
  distance: 22,
  food_expenses: ~M[999],
  car_expenses: ~M[770],
  driver: sara,
  car_owner: sara
})

Repo.insert! %Reimbursement{
  ride: reimbursedRide,
  person: sara,
  food_expenses: ~M[999]
}

Repo.insert! %Reimbursement{
  ride: reimbursedRide,
  person: sara,
  car_expenses: ~M[770]
}

processedRide = Lol.createRide(%{
  relative_start: [days: -50, hours: 8],
  relative_end: [hours: 2, minutes: 15],
  institution: headingley,
  distance: 25,
  food_expenses: ~M[500],
  car_expenses: ~M[700],
  driver: sara,
  car_owner: sara
})

Repo.insert! %Reimbursement{
  ride: processedRide,
  person: sara,
  food_expenses: ~M[500],
  processed: true,
  donation: true
}

Repo.insert! %Reimbursement{
  ride: processedRide,
  person: sara,
  car_expenses: ~M[700],
  processed: true,
  donation: true
}
