defmodule PaymentServerWeb.Resolvers.User do
  @moduledoc """
    Absinthe resolvers for `User`.
  """
  alias PaymentServer.Accounts

  def all(params, _), do: Accounts.list_users(params)

  def find(%{id: id}, _) do
    id
    |> String.to_integer()
    |> Kernel.then(fn id -> %{id: id} end)
    |> Accounts.find_user()
  end

  def create(params, _), do: Accounts.create_user(params)

  def update(%{id: id} = params, _) do
    id
    |> String.to_integer()
    |> Accounts.update_user(Map.delete(params, id))
  end

  def delete(%{id: id}, _) do
    id
    |> String.to_integer()
    |> Accounts.delete_user()
  end
end
