defmodule PaymentServer.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias PaymentServer.Accounts.User
  alias EctoShorts.Actions

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users(%{})
      {:ok, [%Users{}, ...]}

  """
  def list_users(params) do
    case Actions.all(User, params) do
      [] -> {:error, %{message: "not found", details: %{params: params}}}
      users -> {:ok, users}
    end
  end

  @doc """
  Find a single user.

  ## Examples

      iex> find_user(%{id: 123})
      {:ok, %Users{}}

      iex> find_users(%{id: 456})
      {:error, "no user with that id"}

  """
  def find_user(params), do: Actions.find(User, params)

  @doc """
  Creates an user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(params), do: Actions.create(User, Map.merge(params, %{action: :create}))

  @doc """
  Updates an user.

  ## Examples

      iex> update_user(id, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(bad_id, %{field: bad_value})
      {:error, %ErrorMessage{code: :not_found, message: "No item found with id: 2", details: %{}}

  """
  def update_user(id, params), do: Actions.update(User, id, params)

  @doc """
  Deletes an user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, "no user with that id"}

  """
  def delete_user(id), do: Actions.delete(User, id)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking users changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}), do: User.changeset(user, attrs)
end
