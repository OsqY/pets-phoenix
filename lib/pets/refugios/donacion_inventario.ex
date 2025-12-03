defmodule Pets.Refugios.DonacionInventario do
  use Ecto.Schema
  import Ecto.Changeset

  schema "donaciones_inventario" do
    field :cantidad, :float
    field :descripcion, :string
    field :fecha, :date
    field :donante, :string
    field :medida, Ecto.Enum, values: [:unidades, :kg, :litros]
    field :tipo, Ecto.Enum, values: [:comida, :medicina, :utileria]

    belongs_to :refugio, Pets.Cuentas.Usuario

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(donacion_inventario, attrs, usuario_scope) do
    donacion_inventario
    |> cast(attrs, [:cantidad, :descripcion, :fecha, :donante, :medida, :tipo])
    |> validate_required([:cantidad, :descripcion, :fecha, :medida, :tipo])
    |> put_change(:refugio_id, usuario_scope.usuario.id)
  end
end
