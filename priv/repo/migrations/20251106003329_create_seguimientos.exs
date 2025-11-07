defmodule Pets.Repo.Migrations.CreateSeguimientos do
  use Ecto.Migration

  def change do
    create table(:seguimientos) do
      add :fecha, :date
      add :notas, :text
      add :solicitud_id, references(:solicitudes_adopcion, type: :id, on_delete: :delete_all)
      add :responsable_id, references(:usuario, type: :id, on_delete: :delete_all)
      add :usuario_id, references(:usuario, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:seguimientos, [:usuario_id])
  end
end
