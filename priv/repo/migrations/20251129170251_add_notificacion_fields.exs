defmodule Pets.Repo.Migrations.AddNotificacionFields do
  use Ecto.Migration

  def change do
    alter table(:notificaciones) do
      add :tipo, :string, null: false, default: "general"
      add :leida, :boolean, null: false, default: false
      add :referencia_id, :integer
      add :referencia_tipo, :string
    end

    create index(:notificaciones, [:usuario_id, :leida])
    create index(:notificaciones, [:referencia_tipo, :referencia_id])
  end
end
