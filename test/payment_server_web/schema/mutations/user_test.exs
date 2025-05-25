defmodule PaymentServerWeb.Schema.Mutations.UserTest do
  use PaymentServer.DataCase

  alias PaymentServer.{AccountsFixtures, Accounts}
  alias PaymentServerWeb.Schema

  @create_user_doc """
    mutation ($email: String, $name: String, $wallets: [WalletInput]) {
      createUser (email: $email, name: $name, wallets: $wallets) {
        id, name, email,
        wallets {
          name, currency, balance, isDefault
        }
      }
    }
  """
  describe "@create_user" do
    test "create user with valid input no wallet" do
      vars = %{
        "name" => AccountsFixtures.valid_name(),
        "email" => AccountsFixtures.unique_user_email()
      }

      assert {:ok, %{data: data}} = Absinthe.run(@create_user_doc, Schema, variables: vars)
      assert data["createUser"]["email"] === vars["email"]
      assert data["createUser"]["name"] === vars["name"]
    end

    test "create user with invalid input no wallet" do
      vars = %{"name" => nil, "email" => ""}
      assert {:ok, %{errors: errors}} = Absinthe.run(@create_user_doc, Schema, variables: vars)
      assert Kernel.length(errors) === 2
    end

    test "create user with wallet" do
      vars = %{
        "name" => AccountsFixtures.valid_name(),
        "email" => AccountsFixtures.unique_user_email(),
        "wallets" => [
          %{
            "name" => "default wallet",
            "currency" => "VND",
            "balance" => "99.99",
            "isDefault" => true
          }
        ]
      }

      assert {:ok, %{data: data}} = Absinthe.run(@create_user_doc, Schema, variables: vars)
      assert data["createUser"]["email"] === vars["email"]
      assert data["createUser"]["name"] === vars["name"]
      assert data["createUser"]["wallets"] === vars["wallets"]
    end
  end

  @update_user_doc """
    mutation updateUser($id: ID!, $email: String, $name: String) {
      updateUser(id: $id, email: $email, name: $name) {
        id, email, name
      }
    }
  """
  describe "@update_user" do
    setup do
      user = AccountsFixtures.user_fixture()
      %{user: user}
    end

    test "update user with valid input", %{user: user} do
      vars = %{
        "id" => user.id,
        "email" => "updated email",
        "name" => "updated name"
      }

      assert {:ok, %{data: data}} = Absinthe.run(@update_user_doc, Schema, variables: vars)
      assert data["updateUser"]["email"] !== user.email
      assert data["updateUser"]["name"] !== user.name
    end

    test "with invalid input", %{user: user} do
      vars = %{
        "id" => user.id,
        "email" => "",
        "name" => nil
      }

      assert {:ok, %{errors: errors}} = Absinthe.run(@update_user_doc, Schema, variables: vars)
      assert Kernel.length(errors) === 2
    end
  end

  @delete_user_doc """
    mutation deleteUser($id: ID!) {
      deleteUser(id: $id) {
        id, name, email
      }
    }
  """
  describe "@delete_user" do
    setup do
      user = AccountsFixtures.user_fixture()
      %{user: user}
    end

    test "with valid id", %{user: user} do
      vars = %{"id" => user.id}
      assert {:ok, _} = Absinthe.run(@delete_user_doc, Schema, variables: vars)
      assert {:error, error} = Accounts.find_user(%{id: user.id})
      assert error.message =~ "no records found"
    end

    test "with invalid id", %{user: user} do
      vars = %{"id" => user.id + 1}
      assert {:ok, %{errors: [error]}} = Absinthe.run(@delete_user_doc, Schema, variables: vars)
      assert error.message =~ "no records found"
    end
  end
end
