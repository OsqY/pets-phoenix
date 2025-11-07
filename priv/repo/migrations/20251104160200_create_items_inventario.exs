defmodule Pets.Repo.Migrations.CreateItemsInventario do
  use Ecto.Migration

  def change do
    create table(:items_inventario) do
      add :nombre, :string
      add :descripcion, :text
      add :cantidad, :float
      add :medida, :string
      add :tipo, :string
      add :refugio_id, references(:usuario, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:items_inventario, [:refugio_id])
  end
end
