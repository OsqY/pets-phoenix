defmodule Pets.Posts.Comentario do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comentarios" do
    field :contenido, :string
    field :likes, :integer, default: 0

    belongs_to :usuario, Pets.Cuentas.Usuario
    belongs_to :post, Pets.Posts.Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comentario, attrs, usuario_scope) do
    comentario
    |> cast(attrs, [:contenido, :post_id, :likes])
    |> validate_required([:contenido])
    |> put_change(:usuario_id, usuario_scope.usuario.id)
    |> put_default_likes()
  end

  defp put_default_likes(changeset) do
    case get_field(changeset, :likes) do
      nil -> put_change(changeset, :likes, 0)
      _ -> changeset
    end
  end
end
