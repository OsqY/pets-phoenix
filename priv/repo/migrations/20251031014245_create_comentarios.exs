defmodule Pets.Repo.Migrations.CreateComentarios do
  use Ecto.Migration

  def change do
    create table(:comentarios) do
      add :contenido, :text
      add :likes, :integer
      add :usuario_id, references(:usuario, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:comentarios, [:usuario_id])
  end
end
