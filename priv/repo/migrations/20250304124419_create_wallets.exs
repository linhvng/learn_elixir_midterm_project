defmodule PaymentServer.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :name, :string, null: false
      add :currency, :string, null: false
      add :balance, :decimal, default: 0.0
      add :is_default, :boolean, default: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:wallets, [:user_id],
             where: "is_default = true",
             name: :unique_default_wallet
           )
  end
end
