defmodule PaymentServerWeb.Schema.Queries.UserTest do
  use PaymentServer.DataCase

  alias PaymentServer.{Accounts, AccountsFixtures}
  alias PaymentServerWeb.Schema

  setup do
    {:ok, user1} =
      Accounts.create_user(%{
        name: AccountsFixtures.valid_name(),
        email: AccountsFixtures.unique_user_email(),
        wallets: [
          %{
            name: "default wallet",
            balance: Decimal.new("100.00"),
            currency: "USD",
            is_default: true
          }
        ]
      })

    {:ok, user2} =
      Accounts.create_user(%{
        name: AccountsFixtures.valid_name(),
        email: AccountsFixtures.unique_user_email()
      })

    {:ok, user3} =
      Accounts.create_user(%{
        name: AccountsFixtures.valid_name(),
        email: AccountsFixtures.unique_user_email()
      })

    %{users: [user1, user2, user3]}
  end

  @users_doc """
    query users {
      users {
        id, name, email,
        wallets {
          id, balance, currency, isDefault
        }
      }
    }
  """

  describe "@users" do
    test "get all users", %{users: users} do
      assert {:ok, %{data: data}} = Absinthe.run(@users_doc, Schema)
      assert length(data["users"]) === length(users)
    end
  end

  @user_doc """
    query user($id: ID!) {
      user(id: $id) {
        id, name, email,
        wallets {
          id, balance, currency, isDefault
        }
      }
    }
    
  """
  describe "@user" do
    test "find user", %{users: [user1, user2, user3]} do
      vars = %{"id" => user1.id}
      assert {:ok, %{data: data}} = Absinthe.run(@user_doc, Schema, variables: vars)
      assert user = data["user"]
      assert user["id"] === Kernel.to_string(user1.id)
      assert user["id"] !== Kernel.to_string(user2.id)
      assert user["id"] !== Kernel.to_string(user3.id)
    end

    test "find user that does not exist" do
      vars = %{"id" => 0}
      assert {:ok, %{data: data}} = Absinthe.run(@user_doc, Schema, variables: vars)
      assert data["user"] === nil
    end
  end
end
