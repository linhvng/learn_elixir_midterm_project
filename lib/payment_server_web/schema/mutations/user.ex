defmodule PaymentServerWeb.Schema.Mutations.User do
  @moduledoc """
    GraphQL mutations for `User`.
  """
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolvers

  object :user_mutations do
    field :create_user, :user do
      arg :name, :string, description: "User name"
      arg :email, :string, description: "User email"

      arg(
        :wallets,
        list_of(:wallet_input),
        description: "User wallets, must contains one default wallet"
      )

      resolve &Resolvers.User.create/2
    end

    field :update_user, :user do
      arg :id, non_null(:id), description: "User id"
      arg :name, :string, description: "User name"
      arg :email, :string, description: "User email"

      resolve &Resolvers.User.update/2
    end

    field :delete_user, :user do
      arg :id, non_null(:id), description: "User id"

      resolve &Resolvers.User.delete/2
    end
  end
end
