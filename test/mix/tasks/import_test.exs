defmodule Mix.Tasks.ImportTest do
  use ExUnit.Case
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.{Institution, Repo, Request}

  test "something" do
    Mix.Tasks.Import.run "test/support/import/requests.csv"

    [i1, i2] = Repo.all(Institution)

    assert i1.name == "Headingley"
    assert i2.name == "stony mountain"

    [req1, req2, req3] = Repo.all(Request)

    assert req1.address == "91 Albert"
    assert req1.institution_id == i1.id

    assert req2.address == "114 Spence"
    assert req2.institution_id == i2.id

    assert req3.institution_id == i2.id
  end
end
