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

  @doc """
  Changeset para validar el borrado de una especie.
  Previene el borrado si tiene colores o mascotas asociadas.
  """
  def delete_changeset(especie) do
    especie
    |> change()
    |> no_assoc_constraint(:colores,
      message: "No se puede eliminar esta especie porque tiene colores asociados."
    )
    |> no_assoc_constraint(:mascotas,
      message: "No se puede eliminar esta especie porque tiene mascotas asociadas."
    )
  end
end
