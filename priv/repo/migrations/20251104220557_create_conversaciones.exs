defmodule Pets.Repo.Migrations.CreateConversaciones do
  use Ecto.Migration

  def change do
    create table(:conversaciones) do
      add :emisor_id, references(:usuario, type: :id, on_delete: :nothing)
      add :receptor_id, references(:usuario, type: :id, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:conversaciones, [:emisor_id, :receptor_id])
  end
end
