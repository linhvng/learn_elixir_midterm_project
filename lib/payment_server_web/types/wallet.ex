defmodule PaymentServerWeb.Types.Wallet do
  @moduledoc """
    GraphQL type for `Wallet`.
  """
  use Absinthe.Schema.Notation

  @desc "Wallet to hold a single currency and belongs to a single user"
  object :wallet do
    field :id, :id
    field :name, :string
    field :balance, :decimal
    field :currency, :string
    field :is_default, :boolean
    field :user_id, :id
  end

  input_object :wallet_input do
    field :name, :string
    field :balance, :decimal
    field :currency, :string
    field :is_default, :boolean
  end

  @desc "Total worth of an user"
  object :total_worth do
    field :amount, :decimal
    field :currency, :string
  end

  @desc "Result of a transaction"
  object :transaction_result do
    field :sent_amount, :decimal
    field :sent_currency, :string
    field :sender_user_id, :id
    field :receiver_user_id, :id
    field :received_amount, :decimal
    field :received_currency, :string
    field :status, :string
  end

  @desc "Exchange rate"
  object :exchange_rate do
    field :base_currency, :string
    field :update_time, :datetime
    field :rate, :decimal
    field :currency, :string
  end
end
