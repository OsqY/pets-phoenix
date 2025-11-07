defmodule Pets.Repo.Migrations.CreateMensajes do
  use Ecto.Migration

  def change do
    create table(:mensajes) do
      add :contenido, :text
      add :imagen, :string
      add :fecha_hora, :naive_datetime
      add :leido, :boolean, default: false, null: false
      add :conversacion_id, references(:conversaciones, type: :id, on_delete: :nothing)
      add :emisor_id, references(:usuario, type: :id, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:mensajes, [:emisor_id, :conversacion_id])
  end
end
