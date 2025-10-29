defmodule Pets.Mascotas.Mascota do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mascotas" do
    field :nombre, :string
    field :descripcion, :string
    field :edad, :integer
    field :peso, :float
    belongs_to :usuario, Usuario

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mascota, attrs) do
    mascota
    |> cast(attrs, [:nombre, :descripcion, :edad, :peso])
    |> validate_required([:nombre, :descripcion, :edad, :peso])
  end
end
