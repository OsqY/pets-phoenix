defmodule Pets.Repo.Migrations.CreateColores do
  use Ecto.Migration

  def change do
    create table(:colores) do
      add :nombre, :string
      add :especie_id, references(:especies, type: :id, on_delete: :delete_all)
      add :usuario_id, references(:usuario, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:colores, [:usuario_id])
  end
end
