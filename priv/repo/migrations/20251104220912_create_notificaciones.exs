defmodule Pets.Repo.Migrations.CreateNotificaciones do
  use Ecto.Migration

  def change do
    create table(:notificaciones) do
      add :contenido, :text
      add :fecha, :naive_datetime
      add :usuario_id, references(:usuario, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:notificaciones, [:usuario_id])
  end
end
