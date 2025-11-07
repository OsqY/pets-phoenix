defmodule Pets.Repo.Migrations.CreateDonacionesInventario do
  use Ecto.Migration

  def change do
    create table(:donaciones_inventario) do
      add :cantidad, :float
      add :descripcion, :string
      add :fecha, :date
      add :donantes, {:array, :string}
      add :medida, :string
      add :tipo, :string
      add :refugio_id, references(:usuario, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:donaciones_inventario, [:refugio_id])
  end
end
