defmodule Pets.Mascotas.Mascota do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mascotas" do
    field :nombre, :string
    field :descripcion, :string
    field :edad, :integer
    field :sexo, :string
    field :tamanio, :string
    field :peso, :float

    belongs_to :usuario, Pets.Cuentas.Usuario
    belongs_to :color, Pets.Mascotas.Color
    belongs_to :especie, Pets.Mascotas.Especie
    belongs_to :raza, Pets.Mascotas.Raza

    has_many :posts, Pets.Posts.Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mascota, attrs, usuario_scope) do
    mascota
    |> cast(attrs, [
      :nombre,
      :descripcion,
      :edad,
      :sexo,
      :tamanio,
      :peso,
      :color_id,
      :usuario_id,
      :especie_id,
      :raza_id
    ])
    |> validate_required([
      :nombre,
      :descripcion,
      :edad,
      :sexo,
      :tamanio,
      :peso,
      :color_id,
      :usuario_id,
      :especie_id,
      :raza_id
    ])
    |> put_change(:usuario_id, usuario_scope.usuario.id)
  end
end
