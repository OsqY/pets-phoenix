defmodule Pets.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pets.Chats` context.
  """

  @doc """
  Generate a conversacion.
  """
  def conversacion_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        emisor_id: 42,
        receptor_id: 42
      })

    {:ok, conversacion} = Pets.Chats.create_conversacion(scope, attrs)
    conversacion
  end

  @doc """
  Generate a mensaje.
  """
  def mensaje_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        contenido: "some contenido",
        conversacion_id: 42,
        emisor_id: 42,
        fecha_hora: ~N[2025-11-03 22:08:00],
        imagen: "some imagen",
        leido: true
      })

    {:ok, mensaje} = Pets.Chats.create_mensaje(scope, attrs)
    mensaje
  end

  @doc """
  Generate a notificacion.
  """
  def notificacion_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        contenido: "some contenido",
        fehca: ~N[2025-11-03 22:09:00]
      })

    {:ok, notificacion} = Pets.Chats.create_notificacion(scope, attrs)
    notificacion
  end
end
