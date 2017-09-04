defmodule Mix.Tasks.ImportTest do
  use ExUnit.Case
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshare.Repo
  alias PrisonRideshareWeb.{Institution, Person, Reimbursement, Ride}
  alias PaperTrail.Version

  import Money.Sigils

  test "something" do
    Mix.Tasks.Import.run ["test/support/import/requests.csv", "test/support/import/reports.csv", "test/support/import/reimbursements.csv"]

    [i1version, p1version, p2version, req1version, i2version, p3version, _rcw2, _r2, _r3, _r4, _r5, _r6, _r7, _r8, _r9, combiningVersion, reportVersion1, reportVersion2, reiVersion1, _rei2, _rei3, _rei4] = Repo.all(Version)

    [i1, i2] = Repo.all(Institution)

    assert i1.name == "Milner Ridge"
    assert i1.rate == ~M[20]

    assert i2.name == "stony mountain"
    assert i2.rate == ~M[25]

    assert i1version.event == "insert"
    assert i1version.item_changes["name"] == "Milner Ridge"
    assert i1version.item_id == i1.id
    assert i1version.item_type == "Institution"
    assert i1version.origin == "import"

    [req1, reqCombinedWith2, req2, req3, req4, req5, req6, req7, req8, req9] = Ecto.Query.order_by(Ride, :inserted_at)
    |> Repo.all
    |> Repo.preload(:driver)
    |> Repo.preload(:car_owner)

    assert req1.address == "91 Albert"
    assert req1.institution_id == i1.id
    assert Ecto.DateTime.to_erl(req1.start) == {{2016, 8, 5}, {19, 45, 0}}
    assert Ecto.DateTime.to_erl(req1.end) == {{2016, 8, 5}, {20, 45, 0}}
    assert req1.name == "Albert"
    assert req1.contact == "2045551919"
    assert req1.passengers == 2
    assert req1.request_notes == " + walker|We need you"
    assert req1.driver.name == "Lucy Parsons"
    assert req1.car_owner.name == "Oliver Gathing"
    assert req1.enabled

    assert req1version.origin == "import"
    assert req1version.event == "insert"
    assert req1version.item_changes["address"] == "91 Albert"
    assert req1version.item_id == req1.id
    assert req1version.item_type == "Ride"

    assert req1.distance == 75
    assert req1.rate == ~M[27]
    assert req1.food_expenses == ~M[1200]
    assert req1.car_expenses == ~M[2625]
    assert req1.report_notes == "These R the Notes"

    assert reportVersion1.event == "update"
    assert reportVersion1.item_changes["report_notes"] == "These R the Notes"

    assert reqCombinedWith2.combined_with_ride_id == req2.id

    assert combiningVersion.event == "update"
    assert combiningVersion.item_changes["combined_with_ride_id"] == req2.id

    assert req2.address == "114 Spence"
    assert req2.institution_id == i2.id
    assert Ecto.DateTime.to_erl(req2.start) == {{2016, 8, 22}, {8, 15, 0}}
    assert Ecto.DateTime.to_erl(req2.end) == {{2016, 8, 22}, {8, 15, 0}}
    assert req2.driver.name == "Chelsea Manning"
    assert req2.car_owner.name == "Chelsea Manning"
    assert req2.driver == req2.car_owner

    assert req2.report_notes == "These R the Notes again"

    assert req3.address == "MISSING"
    assert req3.institution_id == i2.id
    refute req3.driver
    refute req3.car_owner

    refute req4.enabled
    assert req4.cancellation_reason == "lockdown"

    refute req5.enabled
    assert req5.cancellation_reason == "visitor"
    assert req6.cancellation_reason == "no car"
    assert req7.cancellation_reason == "no driver"

    assert req8.cancellation_reason == "no driver"
    assert req9.cancellation_reason == "visitor"

    [p1, p2, p3] = Repo.all(Person)
    [rei1, rei2, rei3, rei4] = Repo.all(Reimbursement)

    assert p1version.item_changes["name"] == "Lucy Parsons"

    assert rei1.person_id == p1.id
    assert rei1.food_expenses == ~M[1200]

    assert reiVersion1.item_changes["person_id"] == p1.id

    assert rei2.person_id == p2.id
    assert rei2.car_expenses == ~M[2625]

    assert rei3.person_id == p3.id
    assert rei3.car_expenses == ~M[2625]

    assert rei4.person_id == p3.id
    assert rei4.food_expenses == ~M[1100]
  end
end
