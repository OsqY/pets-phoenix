defmodule Pets.Adopciones.SolicitudAdopcion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "solicitudes_adopcion" do
    @solicitudes_estado_options [
      "Pendiente de Revisar": :pendiente,
      Revisado: :revisado,
      Aprobado: :aprobado,
      Rechazado: :rechazado
    ]
    field :estado, Ecto.Enum, values: Keyword.values(@solicitudes_estado_options)
    field :fecha_solicitud, :date
    field :fecha_revision, :date

    belongs_to :adoptante, Pets.Cuentas.Usuario
    belongs_to :mascota, Pets.Mascotas.Mascota
    belongs_to :refugio, Pets.Cuentas.Usuario

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(solicitud_adopcion, attrs, usuario_scope) do
    solicitud_adopcion
    |> cast(attrs, [
      :estado,
      :fecha_solicitud,
      :fecha_revision,
      :adoptante_id,
      :mascota_id,
      :refugio_id
    ])
    |> validate_required([
      :estado,
      :fecha_solicitud,
      :adoptante_id,
      :mascota_id,
      :refugio_id
    ])
    |> put_change(:adoptante_id, usuario_scope.usuario.id)
  end

  def refugio_changeset(solicitud_adopcion, attrs) do
    solicitud_adopcion
    |> cast(attrs, [:estado, :fecha_revision])
    |> validate_required([:estado])
  end

  def solicitudes_estado_options, do: @solicitudes_estado_options

  def humanize_estado(atom) do
    Enum.find_value(@solicitudes_estado_options, "N/A", fn {label, val} ->
      if val == atom, do: label
    end)
  end
end
