defmodule Pets.Mascotas.ImagenMascota do
  use Ecto.Schema
  import Ecto.Changeset

  schema "imagenes_mascotas" do
    field :url, :string

    belongs_to :mascota, Pets.Mascotas.ImagenMascota
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(imagen_mascota, attrs) do
    imagen_mascota
    |> cast(attrs, [:url, :_destroy])
    |> validate_required([:url])
  end
end
