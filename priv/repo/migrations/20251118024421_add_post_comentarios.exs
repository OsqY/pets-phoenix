defmodule Pets.Repo.Migrations.AddPostComentarios do
  use Ecto.Migration

  def change do
    alter table(:comentarios) do
      add :post_id, references(:posts, on_delete: :delete_all)
    end
  end
end
