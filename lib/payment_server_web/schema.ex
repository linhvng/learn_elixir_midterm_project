defmodule PaymentServerWeb.Schema do
  @moduledoc """
    Absinthe GraphQL schema for queries, mutations, and subscriptions of:
    `User`, `Wallet`
  """
  use Absinthe.Schema

  import_types Absinthe.Type.Custom

  import_types PaymentServerWeb.Types.User
  import_types PaymentServerWeb.Types.Wallet

  import_types PaymentServerWeb.Schema.Queries.User
  import_types PaymentServerWeb.Schema.Mutations.User
  # import_types PaymentServerWeb.Schema.Subscriptions.User

  import_types PaymentServerWeb.Schema.Queries.Wallet
  import_types PaymentServerWeb.Schema.Mutations.Wallet
  import_types PaymentServerWeb.Schema.Subscriptions.Wallet

  query do
    import_fields :user_queries
    import_fields :wallet_queries
  end

  mutation do
    import_fields :user_mutations
    import_fields :wallet_mutations
  end

  subscription do
    # import_fields :user_subscriptions
    import_fields :wallet_subscriptions
  end

  def context(ctx) do
    src = Dataloader.Ecto.new(PaymentServer.Repo)

    loader =
      Dataloader.add_source(
        Dataloader.new(),
        PaymentServer.Accounts.User,
        src
      )

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middleware, _field, %Absinthe.Type.Object{identifier: identifier})
      when identifier in [:query, :mutation, :subscription] do
    middleware ++
      [
        PaymentServerWeb.Middlewares.EctoShortsErrorsHandler
      ]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end
end
