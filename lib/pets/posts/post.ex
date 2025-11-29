defmodule Pets.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    field :fecha, :date

    has_many :comentarios, Pets.Posts.Comentario
    has_many :likes, Pets.Posts.Like
    belongs_to :usuario, Pets.Cuentas.Usuario
    belongs_to :mascota, Pets.Mascotas.Mascota

    embeds_many :imagenes_posts, ImagenesPosts, on_replace: :delete do
      field :url, :string
      field :imagen, :any, virtual: true
    end

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs, usuario_scope) do
    post
    |> cast(attrs, [:content, :fecha, :mascota_id, :usuario_id])
    |> validate_required([:content, :fecha, :mascota_id, :usuario_id])
    |> put_change(:usuario_id, usuario_scope.usuario.id)
    |> cast_embed(:imagenes_posts, with: &imagen_post_changeset/2)
  end

  def imagen_post_changeset(imagen, params) do
    imagen |> cast(params, [:url, :imagen])
  end
end
