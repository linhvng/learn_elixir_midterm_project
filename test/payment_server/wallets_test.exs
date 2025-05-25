defmodule PaymentServer.WalletsTest do
  use PaymentServer.DataCase

  import PaymentServer.WalletsFixtures

  alias PaymentServer.{Wallets, Wallets.Wallet, AccountsFixtures}

  describe "wallets" do
    @invalid_attrs %{name: nil, balance: nil, currency: nil, user_id: -1}

    test "list_wallets/1 returns all wallets" do
      wallet = wallet_fixture()
      assert Wallets.list_wallets(%{}) === {:ok, [wallet]}
    end

    test "find_wallet/1 returns the wallet with given id" do
      wallet = wallet_fixture()
      assert Wallets.find_wallet(%{id: wallet.id}) === {:ok, wallet}
    end

    test "create_wallet/1 with valid data creates a wallet" do
      user = AccountsFixtures.user_fixture()

      valid_wallet_attrs = %{
        name: "some name",
        balance: "120.5",
        currency: "USD",
        user_id: user.id
      }

      assert {:ok, %Wallet{} = wallet} = Wallets.create_wallet(valid_wallet_attrs)
      assert wallet.name === "some name"
      assert wallet.balance === Decimal.new("120.5")
      assert wallet.currency === "USD"
    end

    test "create_wallet/1 with another default wallet" do
      user = AccountsFixtures.user_fixture()

      valid_wallet_attrs = %{
        name: "some name",
        balance: "120.5",
        currency: "USD",
        user_id: user.id,
        is_default: true
      }

      assert {:ok, %Wallet{}} = Wallets.create_wallet(valid_wallet_attrs)
      assert {:error, %Ecto.Changeset{}} = Wallets.create_wallet(valid_wallet_attrs)
    end

    test "create_wallet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Wallets.create_wallet(@invalid_attrs)
    end

    test "update_wallet/2 with valid data updates the wallet" do
      wallet = wallet_fixture()

      update_attrs = %{
        name: "some updated name",
        balance: "456.7",
        currency: "EUR"
      }

      assert {:ok, %Wallet{} = wallet} = Wallets.update_wallet(wallet, update_attrs)
      assert wallet.name === "some updated name"
      assert wallet.balance === Decimal.new("456.7")
      assert wallet.currency === "EUR"
    end

    test "update_wallet/2 with invalid data returns error changeset" do
      wallet = wallet_fixture()
      assert {:error, %Ecto.Changeset{}} = Wallets.update_wallet(wallet, @invalid_attrs)
      assert {:ok, wallet} === Wallets.find_wallet(%{id: wallet.id})
    end

    test "delete_wallet/1 deletes the wallet" do
      default_wallet = wallet_fixture()

      second_wallet_attrs = %{
        name: "second wallet",
        balance: "120.5",
        currency: "EUR",
        user_id: default_wallet.user_id
      }

      assert {:ok, %Wallet{} = second_wallet} = Wallets.create_wallet(second_wallet_attrs)
      assert {:ok, %Wallet{}} = Wallets.delete_wallet(second_wallet.id)
      assert {:error, %ErrorMessage{}} = Wallets.find_wallet(%{id: second_wallet.id})
    end

    test "delete_wallet/1 deletes default wallet" do
      wallet = wallet_fixture()

      assert {:error, reason} = Wallets.delete_wallet(wallet.id)
      assert reason.message === "cannot delete default wallet"
      assert {:ok, wallet} === Wallets.find_wallet(%{id: wallet.id})
    end

    test "change_wallet/1 returns a wallet changeset" do
      wallet = wallet_fixture()
      assert %Ecto.Changeset{} = Wallets.change_wallet(wallet)
    end

    test "find_total_worth/1 return a total worth" do
      wallet = wallet_fixture()
      assert {:ok, %{currency: _, amount: _}} = Wallets.find_total_worth(wallet.user_id)
    end
  end

  describe "wallets: send_money/1" do
    setup do
      wallet_from = wallet_fixture()
      wallet_to = wallet_fixture()
      sent_amount = Decimal.new("100.00")

      %{
        wallet_from: wallet_from,
        wallet_to: wallet_to,
        sent_amount: sent_amount,
        params: %{
          sender_wallet_id: wallet_from.id,
          receiver_user_id: wallet_to.user_id,
          sent_amount: sent_amount
        }
      }
    end

    test "send_money/1 send correct amount", ctx do
      assert {:ok, _transaction} = Wallets.send_money(ctx.params)

      new_wallet_from_balance =
        %{id: ctx.wallet_from.id}
        |> Wallets.find_wallet()
        |> Kernel.then(fn {:ok, w} -> w.balance end)

      new_wallet_to_balance =
        %{id: ctx.wallet_to.id}
        |> Wallets.find_wallet()
        |> Kernel.then(fn {:ok, w} -> w.balance end)

      assert new_wallet_from_balance === Decimal.sub(ctx.wallet_from.balance, ctx.sent_amount)
      assert new_wallet_to_balance === Decimal.add(ctx.wallet_to.balance, ctx.sent_amount)
    end

    test "send_money/1 send more than balance", ctx do
      params = Map.merge(ctx.params, %{sent_amount: Decimal.new("1000.00")})
      assert {:error, error} = Wallets.send_money(params)
      assert error.message =~ "exceeds balance"
    end
  end
end
