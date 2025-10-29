defmodule Pets.MascotasFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pets.Mascotas` context.
  """

  @doc """
  Generate a mascota.
  """
  def mascota_fixture(attrs \\ %{}) do
    {:ok, mascota} =
      attrs
      |> Enum.into(%{
        descripcion: "some descripcion",
        edad: 42,
        nombre: "some nombre",
        peso: 120.5
      })
      |> Pets.Mascotas.create_mascota()

    mascota
  end
end
