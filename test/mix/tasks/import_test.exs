defmodule Mix.Tasks.ImportTest do
  use ExUnit.Case
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.{Institution, Repo, Request}

  import Money.Sigils

  test "something" do
    Mix.Tasks.Import.run ["test/support/import/requests.csv"]

    [i1, i2] = Repo.all(Institution)

    assert i1.name == "Milner Ridge"
    assert i1.rate == ~M[25]

    assert i2.name == "stony mountain"
    assert i2.rate == ~M[35]

    [req1, req2, req3] = Repo.all(Request)

    assert req1.address == "91 Albert"
    assert req1.institution_id == i1.id
    assert Ecto.Date.to_erl(req1.date) == {2016, 8, 5}
    assert Ecto.Time.to_erl(req1.start) == {19, 45, 0}
    assert Ecto.Time.to_erl(req1.end) == {20, 45, 0}
    assert req1.name == "Albert"
    assert req1.contact == "2045551919"
    assert req1.passengers == 2
    assert req1.notes == "We need you"

    assert req2.address == "114 Spence"
    assert req2.institution_id == i2.id

    assert req3.address == "MISSING"
    assert req3.institution_id == i2.id
  end
end
