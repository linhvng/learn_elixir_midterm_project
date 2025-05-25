defmodule PaymentServer.Accounts.User do
  @moduledoc """
    schema for an user
    - user can have multiple wallets
    - user has at least 1 default wallet
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string

    has_many :wallets, PaymentServer.Wallets.Wallet

    timestamps(type: :utc_datetime)
  end

  @required_fields [:name, :email]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:wallets)
    |> validate_default_wallet()
  end

  defp validate_default_wallet(changeset) do
    wallets = get_change(changeset, :wallets, [])

    case wallets do
      [] ->
        changeset

      _ ->
        default_wallets =
          Enum.filter(wallets, fn wallet_changeset ->
            Ecto.Changeset.get_field(wallet_changeset, :is_default, false) === true
          end)

        if length(default_wallets) === 1,
          do: changeset,
          else: add_error(changeset, :wallets, "user can have exactly one default wallet")
    end
  end
end
