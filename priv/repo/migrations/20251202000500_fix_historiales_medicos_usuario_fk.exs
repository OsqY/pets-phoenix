defmodule Pets.Repo.Migrations.FixHistorialesMedicosUsuarioFk do
  use Ecto.Migration

  def change do
    drop constraint(:historiales_medicos, "historiales_medicos_usuario_id_fkey")

    alter table(:historiales_medicos) do
      modify :usuario_id, references(:usuario, on_delete: :nothing)
    end
  end
end
