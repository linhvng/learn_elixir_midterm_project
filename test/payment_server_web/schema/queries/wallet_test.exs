defmodule PaymentServerWeb.Schema.Queries.WalletTest do
  use PaymentServer.DataCase

  alias PaymentServer.{Wallets, WalletsFixtures, Currencies}
  alias PaymentServerWeb.Schema

  setup do
    wallet1 = WalletsFixtures.wallet_fixture()

    {:ok, wallet2} =
      PaymentServer.Wallets.create_wallet(%{
        balance: "999.9",
        currency: "USD",
        name: "second wallet",
        user_id: wallet1.user_id
      })

    wallet3 = WalletsFixtures.wallet_fixture()
    wallet4 = WalletsFixtures.wallet_fixture()

    %{wallets: [wallet1, wallet2, wallet3, wallet4]}
  end

  @wallets_doc """
    query wallets ($userId: ID, $currency: String) {
      wallets (userId: $userId, currency: $currency) {
        id, balance, currency, isDefault, name, userId
      }
    }
  """

  describe "@wallets" do
    test "get all wallets", %{wallets: wallets} do
      assert {:ok, %{data: data}} = Absinthe.run(@wallets_doc, Schema)
      assert length(data["wallets"]) === length(wallets)
    end

    test "get wallets by currency" do
      vars = %{"currency" => "USD"}
      assert {:ok, %{data: data}} = Absinthe.run(@wallets_doc, Schema, variables: vars)
      assert {:ok, wallets} = Wallets.list_wallets(%{currency: "USD"})
      assert Kernel.length(wallets) === Kernel.length(data["wallets"])
    end

    test "get wallets by user id", %{wallets: [wallet1 | _]} do
      vars = %{"userId" => wallet1.user_id}
      assert {:ok, %{data: data}} = Absinthe.run(@wallets_doc, Schema, variables: vars)
      assert {:ok, wallets} = Wallets.list_wallets(%{user_id: wallet1.user_id})
      assert Kernel.length(wallets) === Kernel.length(data["wallets"])
    end
  end

  @wallet_doc """
    query wallet ($id: ID!) {
      wallet (id: $id) {
        id, balance, currency, isDefault, name, userId
      }
    }
  """

  describe "@wallet" do
    test "find wallet", %{wallets: [wallet1 | _]} do
      vars = %{"id" => wallet1.id}
      assert {:ok, %{data: data}} = Absinthe.run(@wallet_doc, Schema, variables: vars)
      assert data["wallet"]["id"] === Kernel.to_string(wallet1.id)
    end

    test "find wallet that does not exist" do
      vars = %{"id" => 0}
      assert {:ok, %{data: data}} = Absinthe.run(@wallet_doc, Schema, variables: vars)
      assert data["wallet"] === nil
    end
  end

  @total_worth_doc """
    query totalWorth($userId: ID!, $currency: String) {
      totalWorth (userId: $userId, currency: $currency) {
        amount, currency
      }
    }
  """
  describe "@totalWorth" do
    test "find total worth with default currency", %{wallets: [wallet1, wallet2 | _]} do
      vars = %{"userId" => wallet1.user_id}
      assert {:ok, %{data: data}} = Absinthe.run(@total_worth_doc, Schema, variables: vars)

      assert Decimal.equal?(
               data["totalWorth"]["amount"],
               Decimal.add(wallet1.balance, wallet2.balance)
             )
    end

    test "find total worth with other currency", %{wallets: [wallet1, wallet2 | _]} do
      vars = %{"userId" => wallet1.user_id, "currency" => "JPY"}
      assert {:ok, %{data: data}} = Absinthe.run(@total_worth_doc, Schema, variables: vars)
      assert mock_total = Decimal.add(wallet1.balance, wallet2.balance)
      assert {:ok, mock_total} = Currencies.convert(mock_total, wallet1.currency, "JPY")
      assert Decimal.eq?(data["totalWorth"]["amount"], mock_total, "0.01")
    end
  end
end
