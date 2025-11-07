defmodule Pets.Repo.Migrations.CreateSolicitudesAdopcion do
  use Ecto.Migration

  def change do
    create table(:solicitudes_adopcion) do
      add :estado, :string
      add :fecha_solicitud, :date
      add :fecha_revision, :date
      add :adoptante_id, references(:usuario, type: :id, on_delete: :delete_all)
      add :mascota_id, references(:mascotas, type: :id, on_delete: :delete_all)
      add :refugio_id, references(:usuario, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:solicitudes_adopcion, [:refugio_id, :adoptante_id, :mascota_id])
  end
end
