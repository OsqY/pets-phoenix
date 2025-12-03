defmodule Pets.Adopciones.Seguimiento do
  use Ecto.Schema
  import Ecto.Changeset

  schema "seguimientos" do
    field :fecha, :date
    field :notas, :string
    field :nuevo_estado, :string, virtual: true

    belongs_to :solicitud, Pets.Adopciones.SolicitudAdopcion
    belongs_to :responsable, Pets.Cuentas.Usuario
    belongs_to :usuario, Pets.Cuentas.Usuario

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(seguimiento, attrs, usuario_scope) do
    seguimiento
    |> cast(attrs, [:fecha, :notas, :solicitud_id, :responsable_id, :usuario_id, :nuevo_estado])
    |> validate_required([:notas])
    |> put_change(:responsable_id, usuario_scope.usuario.id)
  end
end
