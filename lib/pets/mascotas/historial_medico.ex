defmodule Pets.Mascotas.HistorialMedico do
  use Ecto.Schema
  import Ecto.Changeset

  @tipos ~w(vacuna desparasitacion consulta cirugia emergencia control chequeo otro)

  schema "historiales_medicos" do
    field :fecha, :date
    field :tipo, :string
    field :descripcion, :string

    belongs_to :mascota, Pets.Mascotas.Mascota
    belongs_to :usuario, Pets.Cuentas.Usuario

    timestamps(type: :utc_datetime)
  end

  def tipos, do: @tipos

  @doc false
  def changeset(historial_medico, attrs, usuario_scope) do
    historial_medico
    |> cast(attrs, [:fecha, :tipo, :descripcion, :mascota_id])
    |> validate_required([:fecha, :tipo, :mascota_id])
    |> validate_inclusion(:tipo, @tipos)
    |> put_change(:usuario_id, usuario_scope.usuario.id)
    |> foreign_key_constraint(:mascota_id)
  end
end
