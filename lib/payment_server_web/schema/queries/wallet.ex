defmodule PaymentServerWeb.Schema.Queries.Wallet do
  @moduledoc """
    GraphQL quries for `Wallet`.
  """
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolvers

  object :wallet_queries do
    field :wallet, :wallet do
      arg :id, non_null(:id), description: "Wallet id"

      resolve &Resolvers.Wallet.find/2
    end

    field :wallets, list_of(:wallet) do
      arg :currency, :string, description: "Wallet currency"
      arg :user_id, :id, description: "User Id whose wallet belongs to"

      resolve &Resolvers.Wallet.all/2
    end

    field :total_worth, :total_worth do
      arg :user_id, non_null(:id), description: "Total worth of user with user_id"

      arg :currency, :string,
        description: "Total worth currency (use user's default currency if blank)"

      resolve &Resolvers.Wallet.find_total_worth/2
    end
  end
end
