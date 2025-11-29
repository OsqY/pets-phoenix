defmodule Pets.Repo.Migrations.AddDescripcionToHistorialesMedicos do
  use Ecto.Migration

  def change do
    alter table(:historiales_medicos) do
      add :descripcion, :text
    end
  end
end
