defmodule Pets.Mascotas.Raza do
  use Ecto.Schema
  import Ecto.Changeset

  schema "razas" do
    field :nombre, :string

    belongs_to :usuario, Pets.Cuentas.Usuario
    has_many :mascotas, Pets.Mascotas.Mascota

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(raza, attrs, usuario_scope) do
    raza
    |> cast(attrs, [:nombre])
    |> validate_required([:nombre])
    |> put_change(:usuario_id, usuario_scope.usuario.id)
  end

  @doc """
  Changeset para validar el borrado de una raza.
  Previene el borrado si tiene mascotas asociadas.
  """
  def delete_changeset(raza) do
    raza
    |> change()
    |> no_assoc_constraint(:mascotas,
      message: "No se puede eliminar esta raza porque tiene mascotas asociadas."
    )
  end
end
