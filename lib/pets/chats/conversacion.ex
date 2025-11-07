defmodule Pets.Chats.Conversacion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversaciones" do
    field :emisor_id, :integer
    field :receptor_id, :integer
    field :usuario_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversacion, attrs, usuario_scope) do
    conversacion
    |> cast(attrs, [:emisor_id, :receptor_id])
    |> validate_required([:emisor_id, :receptor_id])
    |> put_change(:usuario_id, usuario_scope.usuario.id)
  end
end
