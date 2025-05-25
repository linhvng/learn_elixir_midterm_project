defmodule PaymentServer.CurrenciesTest do
  use ExUnit.Case

  alias PaymentServer.Currencies

  describe "currencies" do
    test "all/0 returns a list of supported currencies" do
      currencies = Currencies.all()
      assert is_list(currencies)
      assert %{code: _, name: _, symbol: _} = hd(currencies)
    end

    test "all_codes/0 returns a list of supported currency codes" do
      codes = Currencies.all_codes()
      assert is_list(codes)
      assert codes |> hd() |> is_binary()
    end

    test "find_by_code/1 returns a supported currency" do
      currency = Currencies.find_by_code("VND")
      assert currency.code === "VND"
    end

    test "find_exchange_rate/2" do
      assert %Decimal{} = Currencies.find_exchange_rate("AUD", "JPY")
    end
  end

  describe "currencies: valid?/1" do
    test "valid?/1 tests a supported currency" do
      assert {:ok, "VND"} === Currencies.valid?("VND")
    end

    test "valid?/1 tests a non-supported currency" do
      assert {:error, message} = Currencies.valid?("XYZ")
      assert message =~ "XYZ"
    end
  end

  describe "currencies: convert/3" do
    test "convert/3 with valid inputs" do
      assert {:ok, %Decimal{}} = Currencies.convert(Decimal.new("10.00"), "USD", "VND")
    end

    test "convert/3 with invalid inputs" do
      assert {:error, _reason} = Currencies.convert(Decimal.new("10.00"), "XYZ", "VND")
    end
  end
end
