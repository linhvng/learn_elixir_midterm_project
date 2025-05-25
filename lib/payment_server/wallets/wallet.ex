defmodule PaymentServer.Wallets.Wallet do
  @moduledoc """
    Schema for wallet. User has 1-M relationship with wallets.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "wallets" do
    field :name, :string
    field :balance, :decimal
    field :currency, :string
    field :is_default, :boolean, default: false

    belongs_to :user, PaymentServer.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @required_fields [:name, :currency]
  @available_fields @required_fields ++ [:balance, :is_default, :user_id]

  @doc """
  field `:user_id` is cast but not required so that wallet can be created along with user.
  However, data integrity is preserved with `assoc_contraint`.
  This means wallet cannot be created alone without specify an `:user_id`.
  """
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, @available_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:currency, PaymentServer.Currencies.all_codes())
    |> assoc_constraint(:user)
    |> unique_constraint(:user_id,
      name: :unique_default_wallet,
      message: "already has default wallet"
    )
  end
end
