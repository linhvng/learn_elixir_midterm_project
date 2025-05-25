defmodule PaymentServerWeb.Schema.Mutations.WalletTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServer.{AccountsFixtures, Wallets, WalletsFixtures}
  alias PaymentServerWeb.Schema

  setup do
    user = AccountsFixtures.user_fixture()

    {:ok, wallet_1} =
      Wallets.create_wallet(%{
        name: "first wallet",
        balance: "99.99",
        currency: "AUD",
        user_id: user.id,
        is_default: true
      })

    {:ok, wallet_2} =
      Wallets.create_wallet(%{
        name: "second wallet",
        balance: "99.99",
        currency: "AUD",
        user_id: user.id
      })

    %{user: user, wallets: [wallet_1, wallet_2]}
  end

  @create_wallet_doc """
    mutation (
      $name: String,
      $balance: Decimal,
      $currency: String,
      $userId: ID!,
      $isDefault: Boolean
    ) {
      createWallet (
        name: $name,
        balance: $balance,
        currency: $currency,
        userId: $userId,
        isDefault: $isDefault
      ) {
        id, name, balance, currency, userId, isDefault
      }
    }
  """
  describe "@create_wallet" do
    test "with valid inputs", %{user: user} do
      vars = %{
        "name" => "new wallet",
        "balance" => "99.99",
        "currency" => "VND",
        "userId" => user.id
      }

      assert {:ok, %{data: data}} = Absinthe.run(@create_wallet_doc, Schema, variables: vars)
      assert {:ok, _wallet} = Wallets.find_wallet(%{id: data["createWallet"]["id"]})
    end

    test "with invalid inputs", %{user: user} do
      vars = %{
        "userId" => user.id,
        "name" => "",
        "currency" => "XZY"
      }

      assert {:ok, %{errors: errors}} = Absinthe.run(@create_wallet_doc, Schema, variables: vars)
      assert Kernel.length(errors) === 2
    end
  end

  @update_wallet_doc """
    mutation (
      $id: ID!,
      $name: String,
      $balance: Decimal,
      $currency: String,
      $isDefault: Boolean
    ) {
      updateWallet (
        id: $id,
        name: $name,
        balance: $balance,
        currency: $currency,
        isDefault: $isDefault
      ) {
        id, name, balance, currency, userId, isDefault
      }
    }
  """
  describe "@update_wallet" do
    test "with valid inputs", %{wallets: [_, wallet_2]} do
      vars = %{
        "id" => wallet_2.id,
        "name" => "updated name",
        "balance" => "111.11",
        "currency" => "JPY"
      }

      assert {:ok, %{data: data}} = Absinthe.run(@update_wallet_doc, Schema, variables: vars)
      assert data["updateWallet"]["name"] =~ "updated"
    end

    test "with invalid inputs", %{wallets: [_, wallet_2]} do
      vars = %{
        "id" => wallet_2.id,
        "name" => "",
        "currency" => "XYZ"
      }

      assert {:ok, %{errors: errors}} = Absinthe.run(@update_wallet_doc, Schema, variables: vars)
      assert Kernel.length(errors) === 2
    end

    test "update to have no default wallet", %{wallets: [wallet_1, _]} do
      vars = %{
        "id" => wallet_1.id,
        "isDefault" => false
      }

      assert {:ok, %{errors: errors}} = Absinthe.run(@update_wallet_doc, Schema, variables: vars)
      assert errors |> hd() |> Map.get(:message) =~ "need one default wallet"
    end
  end

  @delete_wallet_doc """
    mutation deleteWallet ($id: ID!) {
      deleteWallet (id: $id) {
        id, name, balance, currency, isDefault, userId
      }
    }
  """
  describe "@delete_wallet" do
    test "with valid inputs", %{wallets: [_, wallet_2]} do
      vars = %{"id" => wallet_2.id}
      assert {:ok, %{data: data}} = Absinthe.run(@delete_wallet_doc, Schema, variables: vars)
      assert data["deleteWallet"]["id"] === Integer.to_string(wallet_2.id)
      assert {:error, _} = Wallets.find_wallet(%{id: wallet_2.id})
    end

    test "delete default wallet", %{wallets: [wallet_1, _]} do
      vars = %{"id" => wallet_1.id}
      assert {:ok, %{errors: errors}} = Absinthe.run(@delete_wallet_doc, Schema, variables: vars)
      assert errors |> hd() |> Map.get(:message) =~ "cannot delete default wallet"
    end
  end

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
  describe "@send_money" do
    setup do
      wallet_from = WalletsFixtures.wallet_fixture()
      wallet_to = WalletsFixtures.wallet_fixture()

      %{wallet_from: wallet_from, wallet_to: wallet_to}
    end

    test "send money with valid inputs", %{wallet_from: wallet_from, wallet_to: wallet_to} do
      vars = %{
        "senderWalletId" => wallet_from.id,
        "receiverUserId" => wallet_to.user_id,
        "sentAmount" => "10.00"
      }

      assert {:ok, %{data: data}} = Absinthe.run(@send_money_doc, Schema, variables: vars)
      assert data["sendMoney"]["status"] =~ "success"
      assert data["sendMoney"]["receivedAmount"] === data["sendMoney"]["sentAmount"]
      assert data["sendMoney"]["receivedCurrency"] === data["sendMoney"]["sentCurrency"]
    end

    test "send money with valid inputs and different currency", %{
      wallet_from: wallet_from,
      wallet_to: wallet_to
    } do
      {:ok, diff_currency_send_wallet} =
        Wallets.create_wallet(%{
          name: "other wallet",
          currency: "JPY",
          balance: "100.00",
          user_id: wallet_from.user_id
        })

      vars = %{
        "senderWalletId" => diff_currency_send_wallet.id,
        "receiverUserId" => wallet_to.user_id,
        "sentAmount" => "10.00"
      }

      assert {:ok, %{data: data}} = Absinthe.run(@send_money_doc, Schema, variables: vars)
      assert data["sendMoney"]["status"] =~ "success"
      assert data["sendMoney"]["receivedAmount"] !== data["sendMoney"]["sentAmount"]
      assert data["sendMoney"]["receivedCurrency"] !== data["sendMoney"]["sentCurrency"]
    end

    test "send amount exceed balance", %{wallet_from: wallet_from, wallet_to: wallet_to} do
      vars = %{
        "senderWalletId" => wallet_from.id,
        "receiverUserId" => wallet_to.user_id,
        "sentAmount" => "1000.00"
      }

      assert {:ok, %{errors: errors}} = Absinthe.run(@send_money_doc, Schema, variables: vars)
      assert errors |> hd() |> Map.get(:message) =~ "exceeds balance"
    end

    test "send money with invalid inputs" do
      vars = %{
        "senderWalletId" => nil,
        "receiverUserId" => nil,
        "sentAmount" => "asdf"
      }

      assert {:ok, %{errors: errors}} = Absinthe.run(@send_money_doc, Schema, variables: vars)
      assert Kernel.length(errors) > 1
    end
  end
end
