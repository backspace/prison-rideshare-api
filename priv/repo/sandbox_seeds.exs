alias PrisonRideshare.Repo
alias PrisonRideshareWeb.{Institution, Person, Reimbursement, Ride, User}

import Money.Sigils

Faker.start

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

    merged = case Map.has_key?(merged, :first_time) do
      true -> Map.merge(merged, %{first_time: params.first_time})
      false -> merged
    end

    PaperTrail.insert! Ride.changeset(%Ride{}, merged), Lol.version_information
  end

  def createPerson(name) do
    PaperTrail.insert! Person.changeset(%Person{
      name: name,
      email: "#{String.replace(String.downcase(name), " ", ".")}@example.com",
      mobile: Faker.Phone.EnUs.phone
    }), Lol.version_information
  end

  def version_information do
    [origin: "sandbox"]
  end
end

user = User.changeset(%User{}, %{
  name: "Sandbox",
  email: "jorts@jants.ca",
  password: "password",
  password_confirmation: "password",
  confirmed_at: Ecto.DateTime.utc
})
|> PaperTrail.insert!(Lol.version_information)

User.admin_changeset(user, %{admin: true})
|> PaperTrail.update!(Lol.version_information)

headingley = PaperTrail.insert! Institution.changeset(%Institution{name: "Headingley", rate: ~M[25]}), Lol.version_information
milner_ridge = PaperTrail.insert! Institution.changeset(%Institution{name: "Milner Ridge", rate: ~M[20]}), Lol.version_information
stony_mountain = PaperTrail.insert! Institution.changeset(%Institution{name: "Stony Mountain", rate: ~M[25]}), Lol.version_information
john_henderson = PaperTrail.insert! Institution.changeset(%Institution{name: "John Henderson Junior High", rate: ~M[40]}), Lol.version_information

cnuth = Lol.createPerson("Cnuth")
sara = Lol.createPerson("Sara Ahmed")
chelsea = Lol.createPerson("Chelsea Manning")
brian = Lol.createPerson("Brian Pallister")

tomorrowRide = Lol.createRide(%{
  relative_start: [days: 1, hours: 13, minutes: 30],
  relative_end: [hours: 1, minutes: 30],
  institution: headingley,
  driver: cnuth,
  car_owner: sara,
  request_notes: "This ride is in the future!"
})

nextWeekRide = Lol.createRide(%{
  relative_start: [days: 7, hours: 15],
  relative_end: [hours: 3],
  institution: milner_ridge,
  first_time: true
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
  car_expenses: ~M[625],
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
  car_expenses: ~M[3000],
  driver: sara,
  car_owner: sara
})

brianRide = Lol.createRide(%{
  relative_start: [days: -9, hours: 5],
  relative_end: [minutes: 45],
  institution: john_henderson,
  distance: 12556,
  food_expenses: ~M[1900000],
  car_expenses: ~M[502240],
  donation: true,
  driver: brian,
  car_owner: brian
})

PaperTrail.insert! %Reimbursement{
  ride: lastMonthRide,
  person: sara,
  food_expenses: ~M[1414]
}, Lol.version_information

PaperTrail.insert! %Reimbursement{
  ride: lastMonthRide,
  person: sara,
  car_expenses: ~M[100]
}, Lol.version_information

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

olderRide = Lol.createRide(%{
  relative_start: [days: -3, hours: 16],
  relative_end: [hours: 2],
  institution: stony_mountain,
  driver: cnuth,
  car_owner: cnuth
})

evenOlderRide = Lol.createRide(%{
  relative_start: [days: -11, hours: 17],
  relative_end: [hours: 2, minutes: 30],
  institution: stony_mountain,
  driver: cnuth,
  car_owner: cnuth
})

reimbursedRide = Lol.createRide(%{
  relative_start: [days: -45, hours: 9],
  relative_end: [hours: 2, minutes: 30],
  institution: headingley,
  distance: 22,
  food_expenses: ~M[999],
  car_expenses: ~M[550],
  driver: sara,
  car_owner: sara
})

PaperTrail.insert! %Reimbursement{
  ride: reimbursedRide,
  person: sara,
  food_expenses: ~M[999]
}, Lol.version_information

PaperTrail.insert! %Reimbursement{
  ride: reimbursedRide,
  person: sara,
  car_expenses: ~M[550]
}, Lol.version_information

processedRide = Lol.createRide(%{
  relative_start: [days: -50, hours: 8],
  relative_end: [hours: 2, minutes: 15],
  institution: headingley,
  distance: 25,
  food_expenses: ~M[500],
  car_expenses: ~M[625],
  driver: sara,
  car_owner: sara
})

PaperTrail.insert! %Reimbursement{
  ride: processedRide,
  person: sara,
  food_expenses: ~M[500],
  processed: true,
  donation: true
}, Lol.version_information

PaperTrail.insert! %Reimbursement{
  ride: processedRide,
  person: sara,
  car_expenses: ~M[625],
  processed: true,
  donation: true
}, Lol.version_information

PaperTrail.insert! %Reimbursement{
  ride: brianRide,
  person: brian,
  food_expenses: ~M[1900000]
}

PaperTrail.insert! %Reimbursement{
  ride: brianRide,
  person: brian,
  car_expenses: ~M[502240],
  donation: true
}
