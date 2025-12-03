defmodule Pets.Chats.Notificacion do
  use Ecto.Schema
  import Ecto.Changeset

  @tipos ~w(solicitud_adopcion cambio_estado_solicitud mensaje_chat comentario_post like_post seguimiento general)

  schema "notificaciones" do
    field :contenido, :string
    field :fecha, :naive_datetime
    field :tipo, :string, default: "general"
    field :leida, :boolean, default: false
    field :referencia_id, :integer
    field :referencia_tipo, :string

    belongs_to :usuario, Pets.Cuentas.Usuario

    timestamps(type: :utc_datetime)
  end

  def tipos, do: @tipos

  @doc false
  def changeset(notificacion, attrs) do
    notificacion
    |> cast(attrs, [:contenido, :fecha, :tipo, :leida, :referencia_id, :referencia_tipo, :usuario_id])
    |> validate_required([:contenido, :tipo, :usuario_id])
    |> validate_inclusion(:tipo, @tipos)
  end

  @doc """
  Changeset para marcar como leída
  """
  def mark_as_read_changeset(notificacion) do
    change(notificacion, leida: true)
  end
end
