defmodule Pets.Repo.Migrations.AddedEmbeddedImagenesMascotas do
  use Ecto.Migration

  def change do
    alter table(:mascotas) do
      add :imagenes, :map
    end
  end
end
