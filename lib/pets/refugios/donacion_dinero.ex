defmodule Pets.Refugios.DonacionDinero do
  use Ecto.Schema
  import Ecto.Changeset

  schema "donaciones_dinero" do
    field :monto, :float
    field :descripcion, :string
    field :fecha, :date
    field :donantes, {:array, :string}

    belongs_to :refugio, Pets.Cuentas.Usuario

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(donacion_dinero, attrs, usuario_scope) do
    donacion_dinero
    |> cast(attrs, [:monto, :descripcion, :fecha, :donantes])
    |> validate_required([:monto, :descripcion, :fecha, :donantes])
    |> put_change(:refugio_id, usuario_scope.usuario.id)
  end
end
