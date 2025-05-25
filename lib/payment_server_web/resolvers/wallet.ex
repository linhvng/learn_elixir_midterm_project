defmodule PaymentServerWeb.Resolvers.Wallet do
  @moduledoc """
    Absinthe resolvers for `Wallet`.
  """
  alias PaymentServer.Wallets

  def all(params, _), do: Wallets.list_wallets(params)

  def find(%{id: id}, _) do
    id
    |> String.to_integer()
    |> Kernel.then(fn id -> %{id: id} end)
    |> Wallets.find_wallet()
  end

  def create(params, _), do: Wallets.create_wallet(params)

  def update(%{id: id} = params, _) do
    old_balance =
      if Map.has_key?(params, :balance),
        do: Wallets.find_wallet(%{id: String.to_integer(id)}),
        else: nil

    id
    |> String.to_integer()
    |> Wallets.update_wallet(Map.delete(params, id))
    |> maybe_publish_total_worth_change(old_balance)
  end

  defp maybe_publish_total_worth_change(result, old_balance) do
    with {:ok, wallet} <- result,
         {:ok, total_worth} <- Wallets.find_total_worth(wallet.user_id) do
      # only publish if balance changes
      if old_balance != wallet.balance do
        Absinthe.Subscription.publish(
          PaymentServerWeb.Endpoint,
          total_worth,
          total_worth_change: "total_worth_change:#{wallet.user_id}"
        )
      end

      {:ok, wallet}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def delete(%{id: id}, _) do
    id
    |> String.to_integer()
    |> Wallets.delete_wallet()
  end

  def find_total_worth(%{user_id: user_id} = params, _) do
    user_id
    |> String.to_integer()
    |> Wallets.find_total_worth(Map.delete(params, :user_id))
  end

  def send_money(params, _) do
    with {:ok, transaction} <- Wallets.send_money(params) do
      {:ok, sender_total_worth} = Wallets.find_total_worth(transaction.sender_user_id)

      Absinthe.Subscription.publish(PaymentServerWeb.Endpoint, sender_total_worth,
        total_worth_change: "total_worth_change:#{transaction.sender_user_id}"
      )

      {:ok, receiver_total_worth} = Wallets.find_total_worth(transaction.receiver_user_id)

      Absinthe.Subscription.publish(PaymentServerWeb.Endpoint, receiver_total_worth,
        total_worth_change: "total_worth_change:#{transaction.receiver_user_id}"
      )

      {:ok, transaction}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end
end
