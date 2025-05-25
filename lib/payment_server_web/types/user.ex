defmodule PaymentServerWeb.Types.User do
  @moduledoc """
    GraphQL type for `User`.
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  @desc "User that has wallets"
  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
    field :wallets, list_of(:wallet), resolve: dataloader(PaymentServer.Accounts.User, :wallets)
  end
end
