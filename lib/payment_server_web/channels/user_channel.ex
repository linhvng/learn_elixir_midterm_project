defmodule PaymentServerWeb.UserChannel do
  @moduledoc """
  Soft-real-time update for `User` via `Phoenix.Channel`.
  Used as backend for `Absinthe.Subscription`.
  """

  use PaymentServerWeb, :channel

  @impl true
  def join("users", _payload, socket), do: {:ok, socket}

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("total_worth_change:*", %{"id" => id}, socket) do
    broadcast(socket, "total_worth_change", %{"id" => id})
    {:reply, %{"accepted" => true}, socket}
  end
end
