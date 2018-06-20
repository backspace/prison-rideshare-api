defmodule Mix.Tasks.ArchiveGasPriceTest do
  use ExUnit.Case
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshare.Repo
  alias PrisonRideshareWeb.GasPrice

  import Money.Sigils
  import Mock

  test_with_mock "running the archiver", HTTPoison,
    get!: fn _url -> %HTTPoison.Response{body: ~s([{
      "pageFunctionResult": "124.917"
    }])} end,
    start: fn -> [] end do
    Mix.Tasks.ArchiveGasPrice.run([])

    [price] = Repo.all(GasPrice)

    assert price.price == ~M[125]
  end
end
