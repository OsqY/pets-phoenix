defmodule Pets.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pets.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        apellidos: "some apellidos",
        correo: "some correo",
        nombre_usuario: "some nombre_usuario",
        nombres: "some nombres"
      })
      |> Pets.Accounts.create_user()

    user
  end
end
