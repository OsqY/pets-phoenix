defmodule Pets.Posts.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes_posts" do
    belongs_to :usuario, Pets.Cuentas.Usuario
    belongs_to :post, Pets.Posts.Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:usuario_id, :post_id])
    |> validate_required([:usuario_id, :post_id])
    |> unique_constraint([:usuario_id, :post_id], name: :likes_posts_usuario_id_post_id_index)
  end
end
