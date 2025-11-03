defmodule Pets.Repo.Migrations.CreateHistorialesMedicos do
  use Ecto.Migration

  def change do
    create table(:historiales_medicos) do
      add :fecha, :date
      add :tipo, :string
      add :mascota_id, references(:mascotas, on_delete: :delete_all)
      add :usuario_id, references(:mascotas, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:historiales_medicos, [:usuario_id])
  end
end
