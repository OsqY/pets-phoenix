defmodule Pets.Repo.Migrations.CreateEspecies do
  use Ecto.Migration

  def change do
    create table(:especies) do
      add :nombre, :string
      add :usuario_id, references(:usuario, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:especies, [:usuario_id])
  end
end
