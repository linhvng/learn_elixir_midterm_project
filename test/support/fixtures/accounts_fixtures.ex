defmodule PaymentServer.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PaymentServer.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_name, do: "John #{System.unique_integer()} Doe"

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        name: valid_name()
      })
      |> PaymentServer.Accounts.create_user()

    user
  end
end
