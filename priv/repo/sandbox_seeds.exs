alias PrisonRideshare.Repo

alias PrisonRideshareWeb.{
  Commitment,
  GasPrice,
  Institution,
  Person,
  Post,
  Reimbursement,
  Ride,
  Slot,
  User
}

import Money.Sigils

Faker.start()

defmodule Lol do
  def createRide(params) do
    today = Timex.beginning_of_day(Timex.local())

    merged =
      Map.merge(params, %{
        start: Ecto.DateTime.cast!(Timex.shift(today, params.relative_start)),
        end:
          Ecto.DateTime.cast!(
            Timex.shift(Timex.shift(today, params.relative_start), params.relative_end)
          ),
        address: Faker.Address.street_address(),
        contact: Faker.Phone.EnUs.phone(),
        name: Faker.Name.first_name(),
        institution_id: params.institution.id
      })

    merged =
      case Map.has_key?(merged, :driver) do
        true -> Map.merge(merged, %{driver_id: params.driver.id})
        false -> merged
      end

    merged =
      case Map.has_key?(merged, :car_owner) do
        true -> Map.merge(merged, %{car_owner_id: params.car_owner.id})
        false -> merged
      end

    merged =
      case Map.has_key?(merged, :first_time) do
        true -> Map.merge(merged, %{first_time: params.first_time})
        false -> merged
      end

    PaperTrail.insert!(Ride.changeset(%Ride{}, merged), Lol.version_information())
  end

  def createPerson(name) do
    PaperTrail.insert!(
      Person.changeset(%Person{
        name: name,
        email: "#{String.replace(String.downcase(name), " ", ".")}@example.com",
        mobile: Faker.Phone.EnUs.phone(),
        address: Faker.Address.street_address(),
      }),
      Lol.version_information()
    )
  end

  def createSlot(params) do
    today = Timex.beginning_of_day(Timex.local())

    Repo.insert!(%Slot{
      start: Ecto.DateTime.cast!(Timex.shift(today, params.relative_start)),
      end: Ecto.DateTime.cast!(
        Timex.shift(Timex.shift(today, params.relative_start), params.relative_end)
      ),
      count: params.count
    })
  end

  def version_information do
    [origin: "sandbox"]
  end
end

user =
  User.changeset(%User{}, %{
    name: "Sandbox",
    email: "jorts@jants.ca",
    password: "password",
    password_confirmation: "password",
    confirmed_at: Ecto.DateTime.utc()
  })
  |> PaperTrail.insert!(Lol.version_information())

User.admin_changeset(user, %{admin: true})
|> PaperTrail.update!(Lol.version_information())

other_user =
  User.changeset(%User{}, %{
    name: "Other",
    email: "other@example.com",
    password: "password",
    password_confirmation: "password",
    confirmed_at: Ecto.DateTime.utc()
  })
  |> PaperTrail.insert!(Lol.version_information())

headingley =
  PaperTrail.insert!(
    Institution.changeset(%Institution{name: "Headingley", far: false}),
    Lol.version_information()
  )

milner_ridge =
  PaperTrail.insert!(
    Institution.changeset(%Institution{name: "Milner Ridge", far: true}),
    Lol.version_information()
  )

stony_mountain =
  PaperTrail.insert!(
    Institution.changeset(%Institution{name: "Stony Mountain", far: false}),
    Lol.version_information()
  )

john_henderson =
  PaperTrail.insert!(
    Institution.changeset(%Institution{name: "John Henderson Junior High", far: false}),
    Lol.version_information()
  )

cnuth = Lol.createPerson("Cnuth")
sara = Lol.createPerson("Sara Ahmed")
chelsea = Lol.createPerson("Chelsea Manning")
brian = Lol.createPerson("Brian Pallister")

tomorrowRide =
  Lol.createRide(%{
    relative_start: [days: 1, hours: 13, minutes: 30],
    relative_end: [hours: 1, minutes: 30],
    institution: headingley,
    driver: cnuth,
    car_owner: sara,
    request_notes: "This ride is in the future!",
    medium: "txt"
  })

nextWeekRide =
  Lol.createRide(%{
    relative_start: [days: 7, hours: 15],
    relative_end: [hours: 3],
    institution: milner_ridge,
    first_time: true,
    medium: "phone"
  })

similarRide =
  Lol.createRide(%{
    relative_start: [days: 7, hours: 15, minutes: 15],
    relative_end: [hours: 3, minutes: 30],
    institution: milner_ridge,
    medium: "phone"
  })

Lol.createRide(%{
  relative_start: [days: 7, hours: 15],
  relative_end: [hours: 3, minutes: 15],
  institution: milner_ridge,
  combined_with_ride_id: nextWeekRide.id,
  medium: "txt"
})

lastWeekRide =
  Lol.createRide(%{
    relative_start: [days: -7, hours: 12],
    relative_end: [hours: 2],
    institution: headingley,
    passengers: 3,
    distance: 25,
    food_expenses: ~M[1200],
    car_expenses: ~M[625],
    request_notes: "Some request notes",
    report_notes: "It happened! These are my notes.",
    driver: chelsea,
    car_owner: chelsea,
    medium: "txt"
  })

lastMonthRide =
  Lol.createRide(%{
    relative_start: [days: -30, hours: 8],
    relative_end: [hours: 4],
    institution: milner_ridge,
    distance: 150,
    food_expenses: ~M[1414],
    car_expenses: ~M[3000],
    driver: sara,
    car_owner: sara,
    medium: "email"
  })

brianRide =
  Lol.createRide(%{
    relative_start: [days: -9, hours: 5],
    relative_end: [minutes: 45],
    institution: john_henderson,
    passengers: 4,
    distance: 12556,
    food_expenses: ~M[1900000],
    car_expenses: ~M[502240],
    donation: true,
    driver: brian,
    car_owner: brian,
    medium: "phone"
  })

PaperTrail.insert!(
  %Reimbursement{
    ride: lastMonthRide,
    person: sara,
    food_expenses: ~M[1414]
  },
  Lol.version_information()
)

PaperTrail.insert!(
  %Reimbursement{
    ride: lastMonthRide,
    person: sara,
    car_expenses: ~M[100]
  },
  Lol.version_information()
)

cancelledRide =
  Lol.createRide(%{
    relative_start: [days: -11, hours: 9],
    relative_end: [hours: 2],
    institution: milner_ridge,
    enabled: false,
    cancellation_reason: "visitor"
  })

yesterdayRide =
  Lol.createRide(%{
    relative_start: [days: -1, hours: 11],
    relative_end: [hours: 1, minutes: 45],
    institution: headingley,
    driver: chelsea,
    car_owner: chelsea
  })

olderRide =
  Lol.createRide(%{
    relative_start: [days: -3, hours: 16],
    relative_end: [hours: 2],
    institution: stony_mountain,
    driver: cnuth,
    car_owner: brian,
    medium: "phone"
  })

evenOlderRide =
  Lol.createRide(%{
    relative_start: [days: -11, hours: 17],
    relative_end: [hours: 2, minutes: 30],
    institution: stony_mountain,
    driver: cnuth,
    car_owner: cnuth,
    medium: "txt"
  })

reimbursedRide =
  Lol.createRide(%{
    relative_start: [days: -45, hours: 9],
    relative_end: [hours: 2, minutes: 30],
    institution: headingley,
    distance: 22,
    food_expenses: ~M[999],
    car_expenses: ~M[550],
    driver: sara,
    car_owner: sara,
    medium: "txt"
  })

PaperTrail.insert!(
  %Reimbursement{
    ride: reimbursedRide,
    person: sara,
    food_expenses: ~M[999]
  },
  Lol.version_information()
)

PaperTrail.insert!(
  %Reimbursement{
    ride: reimbursedRide,
    person: sara,
    car_expenses: ~M[550]
  },
  Lol.version_information()
)

processedRide =
  Lol.createRide(%{
    relative_start: [days: -50, hours: 8],
    relative_end: [hours: 2, minutes: 15],
    institution: headingley,
    distance: 25,
    food_expenses: ~M[500],
    car_expenses: ~M[625],
    driver: sara,
    car_owner: sara,
    medium: "txt"
  })

PaperTrail.insert!(
  %Reimbursement{
    ride: processedRide,
    person: sara,
    food_expenses: ~M[500],
    processed: true,
    donation: true
  },
  Lol.version_information()
)

PaperTrail.insert!(
  %Reimbursement{
    ride: processedRide,
    person: sara,
    car_expenses: ~M[625],
    processed: true,
    donation: true
  },
  Lol.version_information()
)

PaperTrail.insert!(%Reimbursement{
  ride: brianRide,
  person: brian,
  food_expenses: ~M[1900000]
})

PaperTrail.insert!(%Reimbursement{
  ride: brianRide,
  person: brian,
  car_expenses: ~M[502240],
  donation: true
})

today = Timex.beginning_of_day(Timex.local())

Enum.reduce(-60..0, ~M[110], fn days_ago, price ->
  PaperTrail.insert!(%GasPrice{
    inserted_at: Ecto.DateTime.cast!(Timex.add(today, Timex.Duration.from_days(days_ago))),
    price: price
  })

  Money.add(price, Enum.random([-3, -2, -1, 0, 1, 2, 3, 4]))
end)

[a_slot |
  [_ |
    [_ |
      [_ |
        [b_slot | 
          [c_slot | 
            [_ | 
              [_ | 
                [_ |
                  [_ |
                    [_ | 
                      [_ | 
                        [_ | 
                          [_ | 
                            [d_slot | _]]]]]]]]]]]]]]] = Repo.all(Slot)

PaperTrail.insert!(%Commitment{
  person: brian,
  slot: a_slot
})

PaperTrail.insert!(%Commitment{
  person: cnuth,
  slot: b_slot
})

PaperTrail.insert!(%Commitment{
  person: brian,
  slot: c_slot
})

PaperTrail.insert!(%Commitment{
  person: brian,
  slot: d_slot
})

overlapRide =
  Lol.createRide(%{
    relative_start: [days: 6, hours: 13],
    relative_end: [hours: 2, minutes: 30],
    institution: john_henderson,
    medium: "phone"
  })

overlapSlot = PaperTrail.insert!(%Slot{
  start: Timex.shift(overlapRide.start, [hours: -1]),
  end: Timex.shift(overlapRide.end, [minutes: 30]),
})

PaperTrail.insert!(%Commitment{
  person: brian,
  slot: overlapSlot
})

today = Timex.beginning_of_day(Timex.local())

PaperTrail.insert!(%Post{
  poster: user,
  inserted_at: Ecto.DateTime.cast!(Timex.shift(today, [days: -9, hours: 9, minutes: 22])),
  content: "{\"version\":\"0.3.1\",\"atoms\":[],\"cards\":[],\"markups\":[[\"strong\"]],\"sections\":[[1,\"p\",[[0,[],0,\"Here is a blog post with some \"],[0,[0],1,\"bold text\"],[0,[],0,\".\"]]]]}"
})

PaperTrail.insert!(%Post{
  poster: other_user,
  inserted_at: Ecto.DateTime.cast!(Timex.shift(today, [days: -2, hours: 1, minutes: 33])),
  content: "{\"version\":\"0.3.1\",\"atoms\":[],\"cards\":[],\"markups\":[],\"sections\":[[1,\"h1\",[[0,[],0,\"A heading\"]]],[1,\"p\",[[0,[],0,\"This is another blog post by a different user.\"]]]]}"
})