defmodule Pets.Repo.Migrations.AddImagenesPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :imagenes_posts, :map
    end
  end
end
