defmodule Pets.Refugios.ItemInventario do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items_inventario" do
    field :nombre, :string
    field :descripcion, :string
    field :cantidad, :float
    field :medida, Ecto.Enum, values: [:Unidades, :KG, :Litros]
    field :tipo, Ecto.Enum, values: [:Comida, :Medicina, :Utileria]

    belongs_to :refugio, Pets.Cuentas.Usuario

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item_inventario, attrs, usuario_scope) do
    item_inventario
    |> cast(attrs, [:nombre, :descripcion, :cantidad, :medida, :tipo])
    |> validate_required([:nombre, :descripcion, :cantidad, :medida, :tipo])
    |> put_change(:refugio_id, usuario_scope.usuario.id)
  end
end
