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
end
