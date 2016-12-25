defmodule Mix.Tasks.ImportTest do
  use ExUnit.Case
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.{Institution, Repo, Report, Request}

  import Money.Sigils

  test "something" do
    Mix.Tasks.Import.run ["test/support/import/requests.csv", "test/support/import/reports.csv"]

    [i1, i2] = Repo.all(Institution)

    assert i1.name == "Milner Ridge"
    assert i1.rate == ~M[25]

    assert i2.name == "stony mountain"
    assert i2.rate == ~M[35]

    [req1, req2, req3] = Repo.all(Request)
    |> Repo.preload(:report)
    |> Repo.preload(:driver)
    |> Repo.preload(:car_owner)

    assert req1.address == "91 Albert"
    assert req1.institution_id == i1.id
    assert Ecto.Date.to_erl(req1.date) == {2016, 8, 5}
    assert Ecto.Time.to_erl(req1.start) == {19, 45, 0}
    assert Ecto.Time.to_erl(req1.end) == {20, 45, 0}
    assert req1.name == "Albert"
    assert req1.contact == "2045551919"
    assert req1.passengers == 2
    assert req1.notes == "We need you"
    assert req1.driver.name == "Lucy Parsons"
    assert req1.car_owner.name == "Oliver Gathing"

    assert req2.address == "114 Spence"
    assert req2.institution_id == i2.id
    assert Ecto.Time.to_erl(req2.start) == {8, 15, 0}
    assert Ecto.Time.to_erl(req2.end) == {8, 15, 0}
    assert req2.driver.name == "Chelsea Manning"
    assert req2.car_owner.name == "Chelsea Manning"
    assert req2.driver == req2.car_owner

    assert req3.address == "MISSING"
    assert req3.institution_id == i2.id
    refute req3.driver
    refute req3.car_owner

    [rep1] = Repo.all(Report)

    assert rep1.distance == 75
    assert rep1.expenses == ~M[1200]
    assert rep1.notes == "These R the Notes"

    assert req1.report.id == rep1.id
  end
end
