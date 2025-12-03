defmodule Pets.Chats.Conversacion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversaciones" do
    has_many :mensajes, Pets.Chats.Mensaje
    belongs_to :emisor, Pets.Cuentas.Usuario
    belongs_to :receptor, Pets.Cuentas.Usuario

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversacion, attrs) do
    conversacion
    |> cast(attrs, [:emisor_id, :receptor_id])
    |> validate_required([:emisor_id, :receptor_id])
    |> unique_constraint(:emisor_id,
      name: :conversaciones_emisor_id_receptor_id_unique_index,
      message: "Ya existe una conversación entre estos usuarios."
    )
  end


end
