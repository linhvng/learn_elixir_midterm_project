defmodule PaymentServerWeb.Schema.Subscriptions.WalletTest do
  use PaymentServerWeb.SubscriptionCase

  alias PaymentServer.{Wallets, WalletsFixtures}

  @total_worth_change_doc """
    subscription ($userId: ID!) {
      totalWorthChange (userId: $userId) {
        amount, currency
      }
    }
  """

  @send_money_doc """
    mutation sendMoney ($receiverUserId: ID!, $senderWalletId: ID!, $sentAmount: Decimal!) {
      sendMoney (
        receiverUserId: $receiverUserId,
        senderWalletId: $senderWalletId,
        sentAmount: $sentAmount
      ) {
        receivedAmount, receivedCurrency, receiverUserId,
        sentAmount, sentCurrency, senderUserId, 
        status
      }
    }
  """

  describe "@total_worth_change" do
    setup do
      wallet_1 = WalletsFixtures.wallet_fixture()
      wallet_2 = WalletsFixtures.wallet_fixture()

      %{wallets: [wallet_1, wallet_2]}
    end

    test "total worth change after sending money", %{
      wallets: [wallet_1, wallet_2],
      socket: socket
    } do
      assert {:ok, before_balance_1} = Wallets.find_total_worth(wallet_1.user_id)
      assert {:ok, before_balance_2} = Wallets.find_total_worth(wallet_2.user_id)

      sub_vars_1 = %{"userId" => wallet_1.user_id}
      sub_vars_2 = %{"userId" => wallet_2.user_id}

      mut_vars = %{
        "senderWalletId" => wallet_1.id,
        "receiverUserId" => wallet_2.user_id,
        "sentAmount" => "10.00"
      }

      ref = push_doc(socket, @total_worth_change_doc, variables: sub_vars_1)
      assert_reply ref, :ok, %{subscriptionId: subscription_id_1}

      ref = push_doc(socket, @total_worth_change_doc, variables: sub_vars_2)
      assert_reply ref, :ok, %{subscriptionId: subscription_id_2}

      ref = push_doc(socket, @send_money_doc, variables: mut_vars)
      assert_reply ref, :ok, reply
      assert reply.data["sendMoney"]["status"] === "success"

      assert_push "subscription:data", payload_1
      assert subscription_id_1 === payload_1.subscriptionId

      assert_push "subscription:data", payload_2
      assert subscription_id_2 === payload_2.subscriptionId

      after_balance_amount_1 = payload_1.result.data["totalWorthChange"]["amount"]
      assert Decimal.lt?(after_balance_amount_1, before_balance_1.amount)

      after_balance_amount_2 = payload_2.result.data["totalWorthChange"]["amount"]
      assert Decimal.gt?(after_balance_amount_2, before_balance_2.amount)
    end
  end

  @exchange_rate_updated_doc """
    subscription ($currency: String!) {
      exchangeRateUpdated (currency: $currency) {
        rate, currency, updateTime, baseCurrency
      }
    }
  """
  describe "@exchange_rate_updated" do
    test "specific rate updated", %{socket: socket} do
      vars = %{"currency" => "JPY"}
      ref = push_doc(socket, @exchange_rate_updated_doc, variables: vars)
      assert_reply ref, :ok, %{subscriptionId: _subscription_id}

      # mocking new rate
      new_rate = %{
        rate: Decimal.new("0.007"),
        currency: "JPY",
        update_time: DateTime.now!("Etc/UTC"),
        base_currency: Application.get_env(:payment_server, :monitor_currency)
      }

      # simulate exchange rate monitor sending update to subscription
      Absinthe.Subscription.publish(
        PaymentServerWeb.Endpoint,
        new_rate,
        exchange_rate_updated: "exchange_rate_updated:JPY"
      )

      assert_push "subscription:data", payload
      msg = payload.result.data["exchangeRateUpdated"]
      assert msg["rate"] === Decimal.to_string(new_rate.rate)
      assert msg["updateTime"] === DateTime.to_iso8601(new_rate.update_time)
    end
  end

  @exchange_rates_updated_doc """
    subscription {
      exchangeRatesUpdated {
        rate, currency, updateTime, baseCurrency
      }
    }
  """
  describe "@exchange_rates_updated" do
    test "all rates updated", %{socket: socket} do
      ref = push_doc(socket, @exchange_rates_updated_doc)
      assert_reply ref, :ok, %{subscriptionId: _subscription_id}

      # mocking new rate
      now = DateTime.now!("Etc/UTC")

      new_rates =
        PaymentServer.Currencies.all_codes()
        |> Enum.map(fn currency ->
          %{
            rate: :rand.uniform() |> Float.round(2) |> Decimal.from_float(),
            currency: "#{currency}",
            update_time: now,
            base_currency: Application.get_env(:payment_server, :monitor_currency)
          }
        end)

      # simulate exchange rate monitor sending update to subscription
      Absinthe.Subscription.publish(
        PaymentServerWeb.Endpoint,
        new_rates,
        exchange_rates_updated: "exchange_rates_updated"
      )

      assert_push "subscription:data", payload
      msg = payload.result.data["exchangeRatesUpdated"]

      assert Enum.map(msg, fn currency -> Decimal.new(currency["rate"]) end) ===
               Enum.map(new_rates, fn currency -> currency.rate end)

      assert Enum.map(msg, fn currency -> currency["updateTime"] end) ===
               Enum.map(new_rates, fn currency -> DateTime.to_iso8601(currency.update_time) end)
    end
  end
end
