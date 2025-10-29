defmodule Pets.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Pets.Posts.Post

  schema "users" do
    field :nombres, :string
    field :apellidos, :string
    field :correo, :string
    field :nombre_usuario, :string

    has_many :posts, Post
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:nombres, :apellidos, :correo, :nombre_usuario])
    |> validate_required([:nombres, :apellidos, :correo, :nombre_usuario])
  end
end
