defmodule PaymentServerWeb.Middlewares.EctoShortsErrorsHandler do
  @moduledoc """
    This module is responsible for translating errors from ecto shorts to
    Absinthe format
  """
  @behaviour Absinthe.Middleware

  @impl true
  def call(resolution, _config) do
    case resolution.errors do
      [] ->
        resolution

      [%Ecto.Changeset{} = changeset] ->
        errors = Enum.map(changeset.errors, fn {field, {err, _}} -> "#{field}: #{err}" end)

        Absinthe.Resolution.put_result(resolution, {:error, errors})

      _ ->
        error_message =
          resolution.errors
          |> hd()
          |> Map.fetch!(:message)

        Absinthe.Resolution.put_result(resolution, {:error, error_message})
    end
  end
end
