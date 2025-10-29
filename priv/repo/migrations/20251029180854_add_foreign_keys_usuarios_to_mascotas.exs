defmodule Pets.Repo.Migrations.AddForeignKeysUsuariosToMascotas do
  use Ecto.Migration

  def change do
    alter table(:mascotas) do
      add :usuario_id, references(:usuario, on_delete: :nothing)
    end
  end
end
