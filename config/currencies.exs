# This file is responsible for configuring:
# - the supported currencies for PaymentServer.
# - connection for Alpha Vantage api.
#
# To add or remove a new supported currency, add or remove its code (ISO 4217)
# name, and symbol to the list below.
import Config

# Alpha Vantage
# 
# base url to fetch from Alpha Vantage api
config :payment_server, :alpha_vantage_url, "http://localhost:4001/query?"

# Configure supported currencies
config :payment_server, :currencies, [
  %{code: "USD", name: "US Dollar", symbol: "$"},
  %{code: "EUR", name: "Euro", symbol: "€"},
  %{code: "GBP", name: "British Pound", symbol: "£"},
  %{code: "AUD", name: "Australian Dollar", symbol: "A$"},
  %{code: "CAD", name: "Canadian Dollar", symbol: "C$"},
  %{code: "JPY", name: "Japanese Yen", symbol: "¥"},
  %{code: "INR", name: "Indian Rupee", symbol: "₹"},
  %{code: "CNY", name: "Chinese Yuan", symbol: "¥"},
  %{code: "MXN", name: "Mexican Peso", symbol: "MX$"},
  %{code: "BRL", name: "Brazilian Real", symbol: "R$"},
  %{code: "ZAR", name: "South African Rand", symbol: "R"},
  %{code: "CHF", name: "Swiss Franc", symbol: "CHF"},
  %{code: "SEK", name: "Swedish Krona", symbol: "kr"},
  %{code: "NOK", name: "Norwegian Krone", symbol: "kr"},
  %{code: "DKK", name: "Danish Krone", symbol: "kr"},
  %{code: "KRW", name: "South Korean Won", symbol: "₩"},
  %{code: "TRY", name: "Turkish Lira", symbol: "₺"},
  %{code: "SGD", name: "Singapore Dollar", symbol: "S$"},
  %{code: "HKD", name: "Hong Kong Dollar", symbol: "HK$"},
  %{code: "NZD", name: "New Zealand Dollar", symbol: "NZ$"},
  %{code: "SAR", name: "Saudi Riyal", symbol: "ر.س"},
  %{code: "AED", name: "United Arab Emirates Dirham", symbol: "د.إ"},
  %{code: "RUB", name: "Russian Ruble", symbol: "₽"},
  %{code: "IDR", name: "Indonesian Rupiah", symbol: "Rp"},
  %{code: "MYR", name: "Malaysian Ringgit", symbol: "RM"},
  %{code: "THB", name: "Thai Baht", symbol: "฿"},
  %{code: "VND", name: "Vietnamese Dong", symbol: "₫"},
  %{code: "PLN", name: "Polish Zloty", symbol: "zł"},
  %{code: "HUF", name: "Hungarian Forint", symbol: "Ft"},
  %{code: "CZK", name: "Czech Koruna", symbol: "Kč"},
  %{code: "CLP", name: "Chilean Peso", symbol: "CL$"},
  %{code: "COP", name: "Colombian Peso", symbol: "$"},
  %{code: "PEN", name: "Peruvian Nuevo Sol", symbol: "S/."},
  %{code: "EGP", name: "Egyptian Pound", symbol: "ج.م"},
  %{code: "KES", name: "Kenyan Shilling", symbol: "KSh"},
  %{code: "NGN", name: "Nigerian Naira", symbol: "₦"},
  %{code: "PKR", name: "Pakistani Rupee", symbol: "₨"}
]
