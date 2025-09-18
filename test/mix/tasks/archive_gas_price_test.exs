defmodule Mix.Tasks.ArchiveGasPriceTest do
  use ExUnit.Case
  use PrisonRideshareWeb.ConnCase
  use Bamboo.Test

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

  test_with_mock "running the archiver when price-fetching failed sends a report",
                 HTTPoison,
                 get!: fn _url -> %HTTPoison.Response{body: ~s([{}])} end,
                 start: fn -> [] end do
    Mix.Tasks.ArchiveGasPrice.run([])

    assert length(Repo.all(GasPrice)) == 0

    assert_delivered_email(PrisonRideshare.Email.archive_gas_price_failure_report(:missing_value))
  end
end
