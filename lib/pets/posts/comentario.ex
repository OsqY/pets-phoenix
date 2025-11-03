defmodule Pets.Posts.Comentario do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comentarios" do
    field :contenido, :string
    field :likes, :integer

    belongs_to :usuario, Pets.Cuentas.Usuario
    belongs_to :post, Pets.Posts.Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comentario, attrs, usuario_scope) do
    comentario
    |> cast(attrs, [:contenido, :usuario_id, :likes])
    |> validate_required([:contenido, :usuario_id, :likes])
    |> put_change(:usuario_id, usuario_scope.usuario.id)
  end
end
