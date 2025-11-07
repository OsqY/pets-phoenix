defmodule Pets.AdopcionesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pets.Adopciones` context.
  """

  @doc """
  Generate a solicitud_adopcion.
  """
  def solicitud_adopcion_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        adoptante_id: 42,
        estado: :pendiente,
        fecha_revision: ~D[2025-11-05],
        fecha_solicitud: ~D[2025-11-05],
        mascota_id: 42
      })

    {:ok, solicitud_adopcion} = Pets.Adopciones.create_solicitud_adopcion(scope, attrs)
    solicitud_adopcion
  end

  @doc """
  Generate a seguimiento.
  """
  def seguimiento_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        fecha: ~D[2025-11-05],
        notas: "some notas",
        responsable_id: 42,
        solicitud_id: 42
      })

    {:ok, seguimiento} = Pets.Adopciones.create_seguimiento(scope, attrs)
    seguimiento
  end
end
