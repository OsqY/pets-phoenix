defmodule Pets.Chats.Mensaje do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mensajes" do
    field :contenido, :string
    field :imagen, :string
    field :fecha_hora, :naive_datetime
    field :emisor_id, :integer
    field :conversacion_id, :integer
    field :leido, :boolean, default: false
    field :usuario_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mensaje, attrs, usuario_scope) do
    mensaje
    |> cast(attrs, [:contenido, :imagen, :fecha_hora, :emisor_id, :conversacion_id, :leido])
    |> validate_required([:contenido, :imagen, :fecha_hora, :emisor_id, :conversacion_id, :leido])
    |> put_change(:usuario_id, usuario_scope.usuario.id)
  end
end
