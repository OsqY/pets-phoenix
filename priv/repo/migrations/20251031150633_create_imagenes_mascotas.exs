defmodule Pets.Repo.Migrations.CreateImagenesMascotas do
  use Ecto.Migration

  def change do
    create table(:imagenes_mascotas) do
      add :url, :string
      add :mascota_id, references(:mascotas, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
