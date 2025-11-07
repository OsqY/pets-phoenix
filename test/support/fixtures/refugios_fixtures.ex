defmodule Pets.RefugiosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pets.Refugios` context.
  """

  @doc """
  Generate a item_inventario.
  """
  def item_inventario_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        cantidad: 120.5,
        descripcion: "some descripcion",
        medida: "some medida",
        nombre: "some nombre",
        refugio_id: 42,
        tipo: "some tipo"
      })

    {:ok, item_inventario} = Pets.Refugios.create_item_inventario(scope, attrs)
    item_inventario
  end

  @doc """
  Generate a item_inventario.
  """
  def item_inventario_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        cantidad: 120.5,
        descripcion: "some descripcion",
        medida: :unidades,
        nombre: "some nombre",
        refugio_id: 42,
        tipo: :comida
      })

    {:ok, item_inventario} = Pets.Refugios.create_item_inventario(scope, attrs)
    item_inventario
  end

  @doc """
  Generate a donacion_dinero.
  """
  def donacion_dinero_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        descripcion: "some descripcion",
        donantes: ["option1", "option2"],
        fecha: ~D[2025-11-03],
        monto: 120.5,
        refugio_id: 42
      })

    {:ok, donacion_dinero} = Pets.Refugios.create_donacion_dinero(scope, attrs)
    donacion_dinero
  end

  @doc """
  Generate a donacion_inventario.
  """
  def donacion_inventario_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        cantidad: 120.5,
        descripcion: "some descripcion",
        donantes: ["option1", "option2"],
        fecha: ~D[2025-11-03],
        medida: :unidades,
        refugio_id: 42,
        tipo: :comida
      })

    {:ok, donacion_inventario} = Pets.Refugios.create_donacion_inventario(scope, attrs)
    donacion_inventario
  end
end
