defmodule Mix.Tasks.ImportTest do
  use ExUnit.Case
  use PrisonRideshare.ConnCase

  alias PrisonRideshare.{Repo, Request}

  test "something" do
    Mix.Tasks.Import.run "test/support/import/requests.csv"

    [req1, req2] = Repo.all(Request)

    assert req1.address == "91 Albert"
    assert req2.address == "114 Spence"
  end
end
