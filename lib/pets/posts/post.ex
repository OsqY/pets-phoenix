defmodule Pets.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    field :fecha, :date

    has_many :comentarios, Pets.Posts.Comentario
    belongs_to :usuario, Pets.Cuentas.Usuario
    belongs_to :mascota, Pets.Mascotas.Mascota

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs, usuario_scope) do
    post
    |> cast(attrs, [:content, :fecha, :mascota_id, :usuario_id])
    |> validate_required([:content, :fecha, :mascota_id, :usuario_id])
    |> put_change(:usuario_id, usuario_scope.usuario.id)
  end
end
