defmodule PaymentServer.Currencies.AlphaVantageClient do
  @moduledoc """
  This module provides functions to interact with Alpha Vantage api
  """

  @doc """
  Returns the exchange rate from Alpha Vantage.

  ## Examples

    iex> PaymentServer.Currencies.find_exchange_rate("USD", "AUD")
    Decimal.new("1.234")
  """
  @spec find_exchange_rate(String.t(), String.t()) :: Decimal.t()
  def find_exchange_rate(from_currency, to_currency) when from_currency === to_currency,
    do: Decimal.new("1")

  def find_exchange_rate(from_currency, to_currency) do
    base_url = Application.get_env(:payment_server, :alpha_vantage_url)
    function = "function=CURRENCY_EXCHANGE_RATE"
    params = "&from_currency=#{from_currency}&to_currency=#{to_currency}"
    url = "#{base_url}#{function}#{params}"

    url
    |> Req.get!()
    |> then(fn resp -> resp.body["Realtime Currency Exchange Rate"]["5. Exchange Rate"] end)
    |> Decimal.new()
  end
end
