defmodule Pets.Repo.Migrations.RemovedImagenesTable do
  use Ecto.Migration

  def change do
    drop table(:imagenes_mascotas)
  end
end
