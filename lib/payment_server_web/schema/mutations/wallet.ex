defmodule PaymentServerWeb.Schema.Mutations.Wallet do
  @moduledoc """
    GraphQL mutations for `Wallet`.
  """
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolvers

  object :wallet_mutations do
    field :create_wallet, :wallet do
      arg :user_id, non_null(:id), description: "user id of wallet owner"
      arg :name, :string, description: "wallet name"
      arg :balance, :decimal, description: "wallet balance"
      arg :currency, :string, description: "wallet currency"

      arg :is_default, :boolean,
        description: "indicate whether wallet is a default wallet for user"

      resolve &Resolvers.Wallet.create/2
    end

    field :update_wallet, :wallet do
      arg :id, non_null(:id), description: "wallet id"
      arg :name, :string, description: "wallet name"
      arg :balance, :decimal, description: "wallet balance"
      arg :currency, :string, description: "wallet currency"

      arg :is_default, :boolean,
        description: "indicate whether wallet is a default wallet for user"

      resolve &Resolvers.Wallet.update/2
    end

    field :delete_wallet, :wallet do
      arg :id, non_null(:id), description: "wallet id"

      resolve &Resolvers.Wallet.delete/2
    end

    field :send_money, :transaction_result do
      arg :sender_wallet_id, non_null(:id), description: "sender wallet id"
      arg :receiver_user_id, non_null(:id), description: "receiver user id"
      arg :sent_amount, non_null(:decimal), description: "sent amount"

      resolve &Resolvers.Wallet.send_money/2
    end
  end
end
