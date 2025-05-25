defmodule PaymentServer.AccountsTest do
  use PaymentServer.DataCase

  alias PaymentServer.Accounts

  describe "users" do
    alias PaymentServer.Accounts.User

    import PaymentServer.AccountsFixtures

    @invalid_attrs %{name: nil, email: nil, default_currency: nil}

    test "list_users/1 returns all users" do
      user = user_fixture()
      assert Accounts.list_users(%{}) === {:ok, [user]}
    end

    test "find_user/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.find_user(%{id: user.id}) === {:ok, user}
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{name: "some name", email: "some email"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.name === "some name"
      assert user.email === "some email"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        name: "some updated name",
        email: "some updated email"
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.name === "some updated name"
      assert user.email === "some updated email"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert {:ok, user} === Accounts.find_user(%{id: user.id})
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user.id)
      assert {:error, %ErrorMessage{}} = Accounts.find_user(%{id: user.id})
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
