defmodule Pets.Mascotas.HistorialMedico do
  use Ecto.Schema
  import Ecto.Changeset

  schema "historiales_medicos" do
    field :fecha, :date
    field :tipo, :string
    field :mascota_id, :integer
    field :usuario_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(historial_medico, attrs, usuario_scope) do
    historial_medico
    |> cast(attrs, [:fecha, :tipo, :mascota_id])
    |> validate_required([:fecha, :tipo, :mascota_id])
    |> put_change(:usuario_id, usuario_scope.usuario.id)
  end
end
