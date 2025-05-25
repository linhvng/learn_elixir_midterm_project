defmodule PaymentServer.Wallets do
  @moduledoc """
  The Wallets context.
  """

  import Ecto.Query, warn: false

  alias EctoShorts.Actions

  alias PaymentServer.{Wallets.Wallet, Currencies, Repo}

  @doc """
  Returns the list of wallets.

  ## Examples

    iex> list_wallets(%{})
    {:ok, [%Wallets{}, ...]}
  """
  def list_wallets(params) do
    case Actions.all(Wallet, params) do
      [] -> {:error, %{message: "not found", details: %{params: params}}}
      wallets -> {:ok, wallets}
    end
  end

  @doc """
  Find a single wallet.

  ## Examples

    iex> find_wallet(%{id: 123})
    {:ok, %Wallets{}}

    iex> find_wallets(%{id: 456})
    {:error, "no wallet with that id"}
  """
  def find_wallet(params), do: Actions.find(Wallet, params)

  @doc """
  Creates a wallet.
  If it is the first wallet, set it to default.

  ## Examples

    iex> create_wallet(%{field: value})
    {:ok, %Wallet{}}

    iex> create_wallet(%{field: bad_value})
    {:error, %Ecto.Changeset{}}
  """
  def create_wallet(params) do
    is_default? = is_first_wallet?(params.user_id)
    params = Map.put_new(params, :is_default, is_default?)
    Actions.create(Wallet, params)
  end

  defp is_first_wallet?(user_id) do
    count =
      Wallet
      |> where(user_id: ^user_id)
      |> select([w], count(w.id))
      |> Repo.one()

    count === 0
  end

  @doc """
  Updates an wallet.
  If update action is to change default wallet to a non-default wallet, raise error.

  ## Examples

    iex> update_wallet(id, %{field: new_value})
    {:ok, %Wallet{}}

    iex> update_wallet(bad_id, %{field: bad_value})
    {:error, %ErrorMessage{code: :not_found, message: "No item found with id: 2", details: %{}}
  """
  def update_wallet(id, %{is_default: is_default} = params) do
    {:ok, wallet} = find_wallet(%{id: id})
    {:ok, default_wallet} = find_wallet(%{user_id: wallet.user_id, is_default: true})

    cond do
      wallet.id === default_wallet.id and is_default === false ->
        {:error, %{message: "need one default wallet"}}

      wallet.id !== default_wallet.id and is_default === true ->
        Actions.update(Wallet, default_wallet.id, %{is_default: false})
        Actions.update(Wallet, wallet.id, %{is_default: true})
        update_wallet(id, params)

      true ->
        {_, params} = Map.pop!(params, :is_default)
        update_wallet(id, params)
    end
  end

  def update_wallet(id, params), do: Actions.update(Wallet, id, params)

  @doc """
  Deletes an wallet.

  ## Examples

    iex> delete_wallet(id)
    {:ok, %Wallet{}}

    iex> delete_wallet(id)
    {:error, "no wallet with that id"}
  """
  def delete_wallet(id) do
    {:ok, wallet} = find_wallet(%{id: id})

    if wallet.is_default do
      {:error, %{message: "cannot delete default wallet"}}
    else
      Actions.delete(Wallet, id)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking wallet changes.

  ## Examples

    iex> change_wallet(wallet)
    %Ecto.Changeset{data: %Wallet{}}
  """
  def change_wallet(%Wallet{} = wallet, attrs \\ %{}), do: Wallet.changeset(wallet, attrs)

  @doc """
  Returns an user's total worth amount in a specific currency.
  If no currency specified, use their default wallet currency.

  ## Examples

    iex> find_total_worth(user_id, %{currency: "USD"})
    {:ok, ${amount: Decimal.new("1234"), currency: "USD"}}

    iex> find_total_worth(user_id, %{currency: "xyz"})
    {:error, %{message: "no wallet found"}}
  """

  def find_total_worth(user_id, params \\ %{currency: ""})

  def find_total_worth(user_id, %{currency: currency}) when currency === "" do
    {:ok, default_wallet} = find_wallet(%{user_id: user_id, is_default: true})
    find_total_worth(user_id, %{currency: default_wallet.currency})
  end

  def find_total_worth(user_id, %{currency: currency}) do
    case list_wallets(%{user_id: user_id}) do
      {:ok, wallets} ->
        total_worth =
          wallets
          |> Enum.map(fn w -> Currencies.convert(w.balance, w.currency, currency) end)
          |> Enum.map(fn {:ok, balance} -> balance end)
          |> Enum.reduce(fn balance, total_worth -> Decimal.add(balance, total_worth) end)

        {:ok, %{amount: total_worth, currency: currency}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def find_total_worth(user_id, %{}), do: find_total_worth(user_id, %{currency: ""})

  @doc """
  Send money from a specific wallet to another user.

  If the receiver has a wallet with the same currency as the source wallet, use
  that currency.

  If the receiver has no wallet with the same currency as the
  source wallet, use the receiver's default currency.

  ## Examples

    iex> send_money(%{sender_wallet_id: 60, receiver_user_id: 10, send_amount: "9.99"})
    {:ok,
     %{
       sent_amount: sent_amount,
       sent_currency: source_wallet.currency,
       sender_user_id: source_wallet.user_id,
       received_amount: receive_amount,
       received_currency: receiver_wallet.currency,
       receiver_user_id: receiver_user_id,
       status: "success"
    }}

    iex> send_money(%{sender_wallet_id: 60, receiver_user_id: 10, send_amount: "999999.99"})
    {:error, %{message: "send amount exceeds balance"}}
  """
  def send_money(%{
        sender_wallet_id: source_wallet_id,
        receiver_user_id: receiver_user_id,
        sent_amount: sent_amount
      }) do
    {:ok, source_wallet} = find_wallet(%{id: source_wallet_id})
    {:ok, receiver_wallets} = list_wallets(%{user_id: receiver_user_id})
    sent_amount = Decimal.new(sent_amount)

    receiver_default_wallet =
      receiver_wallets |> Enum.filter(fn w -> w.is_default end) |> Kernel.hd()

    receiver_wallet =
      Enum.find(receiver_wallets, receiver_default_wallet, fn w ->
        w.currency === source_wallet.currency
      end)

    {:ok, receive_amount} =
      Currencies.convert(sent_amount, source_wallet.currency, receiver_wallet.currency)

    new_sender_balance =
      Decimal.sub(source_wallet.balance, sent_amount)

    new_receiver_balance =
      Decimal.add(receiver_wallet.balance, receive_amount)

    with true <- Decimal.gte?(new_sender_balance, 0),
         {:ok, _} <- update_wallet(source_wallet_id, %{balance: new_sender_balance}),
         {:ok, _} <- update_wallet(receiver_wallet.id, %{balance: new_receiver_balance}) do
      {:ok,
       %{
         sent_amount: sent_amount,
         sent_currency: source_wallet.currency,
         sender_user_id: source_wallet.user_id,
         received_amount: receive_amount,
         received_currency: receiver_wallet.currency,
         receiver_user_id: receiver_user_id,
         status: "success"
       }}
    else
      false ->
        {:error, %{message: "send amount exceeds balance"}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
