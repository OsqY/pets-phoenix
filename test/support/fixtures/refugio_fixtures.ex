defmodule Pets.RefugioFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pets.Refugio` context.
  """

  @doc """
  Generate a historial_medio.
  """
  def historial_medio_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        fecha: ~D[2025-11-04],
        mascota_id: 42,
        refugio_id: 42,
        tipo: :vacuna
      })

    {:ok, historial_medio} = Pets.Refugio.create_historial_medio(scope, attrs)
    historial_medio
  end
end
