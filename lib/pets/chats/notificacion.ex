defmodule Pets.Chats.Notificacion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notificaciones" do
    field :contenido, :string
    field :fehca, :naive_datetime
    field :usuario_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notificacion, attrs, usuario_scope) do
    notificacion
    |> cast(attrs, [:contenido, :fehca])
    |> validate_required([:contenido, :fehca])
    |> put_change(:usuario_id, usuario_scope.usuario.id)
  end
end
