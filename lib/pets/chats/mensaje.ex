defmodule Pets.Chats.Mensaje do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mensajes" do
    field :contenido, :string
    field :imagen, :string
    field :leido, :boolean, default: false

    belongs_to :emisor, Pets.Cuentas.Usuario
    belongs_to :conversacion, Pets.Chats.Conversacion

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mensaje, attrs, usuario_scope) do
    mensaje
    |> cast(attrs, [:contenido, :imagen, :emisor_id, :conversacion_id, :leido])
    |> validate_required([:contenido, :emisor_id, :conversacion_id])
    |> put_change(:emisor_id, usuario_scope.usuario.id)
  end
end
