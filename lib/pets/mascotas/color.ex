defmodule Pets.Mascotas.Color do
  use Ecto.Schema
  import Ecto.Changeset

  schema "colores" do
    field :nombre, :string

    belongs_to :usuario, Pets.Cuentas.Usuario
    belongs_to :especie, Pets.Mascotas.Especie
    has_many :mascotas, Pets.Mascotas.Mascota

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(color, attrs, usuario_scope) do
    color
    |> cast(attrs, [:nombre, :especie_id])
    |> validate_required([:nombre, :especie_id])
    |> put_change(:usuario_id, usuario_scope.usuario.id)
  end

  @doc """
  Changeset para validar el borrado de un color.
  Previene el borrado si tiene mascotas asociadas.
  """
  def delete_changeset(color) do
    color
    |> change()
    |> no_assoc_constraint(:mascotas,
      message: "No se puede eliminar este color porque tiene mascotas asociadas."
    )
  end
end
