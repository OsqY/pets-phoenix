defmodule Pets.Mascotas.Especie do
  use Ecto.Schema
  import Ecto.Changeset

  schema "especies" do
    field :nombre, :string

    has_many :colores, Pets.Mascotas.Color
    has_many :mascotas, Pets.Mascotas.Mascota

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(especie, attrs, usuario_scope) do
    especie
    |> cast(attrs, [:nombre])
    |> validate_required([:nombre])
  end
end
