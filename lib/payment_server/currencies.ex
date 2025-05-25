defmodule PaymentServer.Currencies do
  @moduledoc """
  This module provides functions to:
    - interact with the list of currencies, set in `configs/currencies.exs`
  """

  alias PaymentServer.Currencies

  defdelegate find_exchange_rate(from, to), to: Currencies.AlphaVantageClient

  @doc """
  This function returns a list of all supported currencies specified in config.
  The currency map contains currency code (ISO 4217), name, and symbol.

  ## Examples

    iex> Currencies.all()
    [
      %{code: "USD", name: "US Dollar", symbol: "$"},
      %{code: "EUR", name: "Euro", symbol: "€"},
      %{code: "GBP", name: "British Pound", symbol: "£"},
      ...
      %{code: "PKR", name: "Pakistani Rupee", symbol: "₨"}
    ]
  """
  def all, do: Application.get_env(:payment_server, :currencies, [])

  @doc """
  This function returns a list of codes (ISO 4217) for all supported currencies.

  ## Examples

    iex> Currencies.all_codes()
    ["USD", "EUR", ..., "PKR"]
  """
  def all_codes, do: Enum.map(all(), & &1[:code])

  @doc """
  This function returns a currency when given a currency code (ISO 4217).

  ## Examples

    iex> Currencies.find_by_code("USD")
    %{code: "USD", name: "US Dollar", symbol: "$"}
  """
  def find_by_code(code), do: Enum.find(all(), fn currency -> currency[:code] === code end)

  @doc """
  This function check if a currency is supported when given a currency code (ISO 4217).

  ## Examples

    iex> Currencies.valid?("USD")
    {:ok, "USD"}

    iex> Currencies.valid?("XYZ")
    {:error, "XYZ is not supported"}
  """
  def valid?(code) do
    if code in all_codes(),
      do: {:ok, code},
      else: {:error, "#{code} is not supported"}
  end

  @doc """
  This function returs the amount value in `to_currency`.
  It gets the rate from the cached rates in exchange rate monitor.

  ## Example:
    iex> PaymentServer.Currencies.convert(Decimal.new("123.45"), "USD", "EUR")
    {:ok, Decimal.new("321.54")}

    iex> PaymentServer.Currencies.convert(Decimal.new("123.45"), "XYZ", "EUR")
    {:error, "XYZ is not supported"}
  """
  def convert(%Decimal{} = amount, from_currency, to_currency) do
    with {:ok, from_currency} <- valid?(from_currency),
         {:ok, to_currency} <- valid?(to_currency) do
      latest_rates = Currencies.ExchangeRateMonitor.get_rates([from_currency, to_currency])

      from_curency_vs_usd =
        Enum.find(latest_rates.rates, fn rate -> rate.currency === from_currency end)

      to_currency_vs_usd =
        Enum.find(latest_rates.rates, fn rate -> rate.currency === to_currency end)

      rate = Decimal.div(from_curency_vs_usd.rate, to_currency_vs_usd.rate)

      {:ok, amount |> Decimal.mult(rate) |> Decimal.round(2)}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
