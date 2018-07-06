defmodule PrisonRideshareWeb.GasPriceControllerTest do
  use PrisonRideshareWeb.ConnCase
  use Bamboo.Test

  alias PrisonRideshareWeb.GasPrice
  alias PrisonRideshare.Repo

  import Money.Sigils

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "lists all prices", %{conn: conn} do
    price =
      Repo.insert!(%GasPrice{
        price: ~M[105],
        inserted_at: Ecto.DateTime.from_erl({{2018, 7, 6}, {9, 29, 0}})
      })

    conn = get(conn, gas_price_path(conn, :index))

    assert json_response(conn, 200)["data"] == [
             %{
               "id" => price.id,
               "type" => "gas-price",
               "attributes" => %{
                 "price" => 105,
                 "far-rate" => 21,
                 "close-rate" => 26,
                 "inserted-at" => "2018-07-06T09:29:00.000000Z"
               }
             }
           ]
  end
end
