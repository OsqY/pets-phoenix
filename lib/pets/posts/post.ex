defmodule Pets.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Pets.Accounts.User

  schema "posts" do
    field :content, :string
    field :fecha, :date, default: Date.utc_today()
    field :mascota_id, :integer

    belongs_to :usuario, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content, :fecha, :mascota_id, :usuario_id])
    |> validate_required([:content, :fecha, :usuario_id])
    |> validate_length(:content, max: 500)
    |> assoc_constraint(:usuario)
  end
end
