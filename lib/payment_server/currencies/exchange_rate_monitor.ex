defmodule PaymentServer.Currencies.ExchangeRateMonitor do
  @moduledoc """
    GenServer to fetch exchange in an interval per.
    If the exchange rate changes, publish a message to channel.

    The monitor must be:
      - process based monitoring
        - must be able to fetch rates in interval
        - interval specified in config
      - rates will be USD base (!IMPORTANT!)
        - must be able to change in config
      - can fetch specific rate from state
  """
  use GenServer

  alias PaymentServer.Currencies

  # API
  # ========

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)

    initial_state = %{
      rates: [],
      update_time: nil,
      base_currency: Application.get_env(:payment_server, :monitor_currency)
    }

    GenServer.start_link(__MODULE__, initial_state, opts)
  end

  def stop(), do: GenServer.stop(__MODULE__, :normal)
  def get_rates(currencies), do: GenServer.call(__MODULE__, {:get_rates, currencies})

  # Server
  # ========

  @impl true
  def init(state) do
    # fetch the first time
    send(self(), :fetch_rates)

    # then schedule to fetch every interval
    interval = Application.get_env(:payment_server, :monitor_interval)
    :timer.send_interval(interval, :fetch_rates)

    {:ok, state}
  end

  @impl true
  def handle_info(:fetch_rates, state) do
    rates =
      Currencies.all_codes()
      |> List.delete(state.base_currency)
      |> Task.async_stream(fn currency ->
        rate = Currencies.find_exchange_rate(state.base_currency, currency)
        %{rate: rate, currency: currency}
      end)
      |> Enum.map(fn {:ok, result} -> result end)
      |> Kernel.++([%{rate: Decimal.new("1.00"), currency: state.base_currency}])

    new_state =
      state
      |> Map.replace!(:update_time, DateTime.now!("Etc/UTC"))
      |> Map.replace!(:rates, rates)

    send(self(), :publish_rates)

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:publish_rates, state) do
    additional_info = %{
      base_currency: state.base_currency,
      update_time: state.update_time
    }

    rates_to_publish = Enum.map(state.rates, fn rate -> Map.merge(rate, additional_info) end)

    # publish to all specific rate channels
    Enum.each(rates_to_publish, fn currency ->
      Absinthe.Subscription.publish(
        PaymentServerWeb.Endpoint,
        currency,
        exchange_rate_updated: "exchange_rate_updated:#{currency.currency}"
      )
    end)

    # publish to all rates channel
    Absinthe.Subscription.publish(
      PaymentServerWeb.Endpoint,
      rates_to_publish,
      exchange_rates_updated: "exchange_rates_updated"
    )

    {:noreply, state}
  end

  @impl true
  def handle_call({:get_rates, currencies}, _from, state) do
    rates = Enum.filter(state.rates, fn %{currency: currency} -> currency in currencies end)
    result = Map.replace!(state, :rates, rates)
    {:reply, result, state}
  end
end
