defmodule Pets.Mascotas.ImagenMascota do
  use Ecto.Schema
  import Ecto.Changeset

  schema "imagenes_mascotas" do
    field :url, :string

    belongs_to :mascota, Mascota
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(imagen_mascota, attrs, usuario_scope) do
    imagen_mascota
    |> cast(attrs, [:url, :mascota_id])
    |> validate_required([:url, :mascota_id])
    |> put_change(:usuario_id, usuario_scope.usuario.id)
  end
end
