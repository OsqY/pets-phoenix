defmodule Pets.MascotasFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pets.Mascotas` context.
  """

  @doc """
  Generate a raza.
  """
  def raza_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        nombre: "some nombre"
      })

    {:ok, raza} = Pets.Mascotas.create_raza(scope, attrs)
    raza
  end

  @doc """
  Generate a especie.
  """
  def especie_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        nombre: "some nombre"
      })

    {:ok, especie} = Pets.Mascotas.create_especie(scope, attrs)
    especie
  end

  @doc """
  Generate a color.
  """
  def color_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        especie_id: 42,
        nombre: "some nombre"
      })

    {:ok, color} = Pets.Mascotas.create_color(scope, attrs)
    color
  end

  @doc """
  Generate a mascota.
  """
  def mascota_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        color_id: 42,
        descripcion: "some descripcion",
        edad: 42,
        especie_id: 42,
        nombre: "some nombre",
        peso: 120.5,
        raza_id: 42,
        sexo: "some sexo",
        tamanio: "some tamanio",
        usuario_id: 42
      })

    {:ok, mascota} = Pets.Mascotas.create_mascota(scope, attrs)
    mascota
  end

  @doc """
  Generate a imagen_mascota.
  """
  def imagen_mascota_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        mascota_id: 42,
        url: "some url"
      })

    {:ok, imagen_mascota} = Pets.Mascotas.create_imagen_mascota(scope, attrs)
    imagen_mascota
  end

  @doc """
  Generate a historial_medico.
  """
  def historial_medico_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        fecha: ~D[2025-10-30],
        mascota_id: 42,
        tipo: "some tipo"
      })

    {:ok, historial_medico} = Pets.Mascotas.create_historial_medico(scope, attrs)
    historial_medico
  end
end
