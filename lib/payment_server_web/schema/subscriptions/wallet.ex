defmodule PaymentServerWeb.Schema.Subscriptions.Wallet do
  @moduledoc """
  Soft-real-time updates via GraphQL for `User` event.
  """
  use Absinthe.Schema.Notation

  object :wallet_subscriptions do
    field :total_worth_change, :total_worth do
      arg :user_id, non_null(:id), description: "User id"

      arg :currency, :string,
        description: "Currency to monitor total worth in, use user's default currency if blank."

      config(fn args, _info ->
        topic = "total_worth_change:#{args.user_id}"
        {:ok, topic: topic}
      end)
    end

    field :exchange_rate_updated, :exchange_rate do
      arg :currency, non_null(:string), description: "Currency to monitor"

      config(fn args, _info ->
        {:ok, topic: "exchange_rate_updated:#{args.currency}", context_id: "global"}
      end)
    end

    field :exchange_rates_updated, list_of(:exchange_rate) do
      config(fn _args, _info ->
        {:ok, topic: "exchange_rates_updated", context_id: "global"}
      end)
    end
  end
end
