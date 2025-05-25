# This file is responsible for configuring:
# - the interval for the exchange rate monitor
# - the default currency for exchange rate monitor
#
import Config

# interval to fetch from Alpha Vantage in miliseconds
config :payment_server, :monitor_interval, 5_000

# default currency as base
config :payment_server, :monitor_currency, "USD"
