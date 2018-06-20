defmodule PrisonRideshare.ExtractGasPriceTest do
  use ExUnit.Case
  alias PrisonRideshare.ExtractGasPrice

  test "it extracts the price" do
    example = ~s([{
      "loadedUrl": "http://www.winnipeggasprices.com/",
      "loadingStartedAt": "2018-06-13T08:00:01.711Z",
      "loadingFinishedAt": "2018-06-13T08:00:11.531Z",
      "loadErrorCode": null,
      "pageFunctionStartedAt": "2018-06-13T08:00:13.894Z",
      "pageFunctionFinishedAt": "2018-06-13T08:00:14.120Z",
      "isMainFrame": true,
      "postData": null,
      "contentType": null,
      "method": "GET",
      "willLoad": true,
      "errorInfo": "",
      "pageFunctionResult": "124.917",
      "interceptRequestData": null,
      "downloadedBytes": 5004996,
      "queuePosition": "LAST",
      "proxy": null,
      "responseStatus": 200,
      "responseHeaders": {
        "Date": "Wed, 13 Jun 2018 08:00:01 GMT",
        "Content-Type": "text/html; charset=utf-8",
        "Transfer-Encoding": "chunked",
        "Connection": "keep-alive",
        "Cache-Control": "no-cache, no-store",
        "Pragma": "no-cache",
        "Expires": "-1",
        "Vary": "Accept-Encoding",
        "Set-Cookie": "__cfduid=d51ca4861c98171da9e60b04832a271921528876801; expires=Thu, 13-Jun-19 08:00:01 GMT; path=/; domain=.winnipeggasprices.com; HttpOnly\nASP.NET_SessionId=eqp33ihmazciok3jxh5e2wao; path=/; HttpOnly",
        "X-AspNet-Version": "4.0.30319",
        "X-Powered-By": "ASP.NET",
        "X-Node": "07",
        "Server": "cloudflare",
        "CF-RAY": "42a3056ad35f242c-IAD",
        "Content-Encoding": "gzip"
      },
      "id": "V6sUpVDUh5zD3mH",
      "url": "http://www.winnipeggasprices.com/",
      "requestedAt": "2018-06-13T08:00:01.383Z",
      "uniqueKey": "http://www.winnipeggasprices.com",
      "type": "StartUrl",
      "label": null,
      "referrerId": null,
      "depth": 0,
      "storageBytes": 1082
    }])

    parsed = Poison.decode!(example)

    assert ExtractGasPrice.extract_gas_price(parsed) == %{
             price: 124.917
           }
  end
end
