defmodule PaymentServer.WalletsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PaymentServer.Wallets` context.
  """

  alias PaymentServer.AccountsFixtures

  @doc """
  Generate a wallet.
  """
  def wallet_fixture(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture()

    {:ok, wallet} =
      %{
        balance: "120.5",
        currency: "USD",
        name: "some name",
        user_id: user.id
      }
      |> Map.merge(attrs)
      |> PaymentServer.Wallets.create_wallet()

    wallet
  end
end
