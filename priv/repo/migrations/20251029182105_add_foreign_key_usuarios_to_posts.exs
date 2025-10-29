defmodule Pets.Repo.Migrations.AddForeignKeyUsuariosToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :usuario_id, references(:usuario, on_delete: :nothing)
    end
  end
end
