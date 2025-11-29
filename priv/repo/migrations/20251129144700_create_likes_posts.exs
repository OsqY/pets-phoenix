defmodule Pets.Repo.Migrations.CreateLikesPosts do
  use Ecto.Migration

  def change do
    create table(:likes_posts) do
      add :usuario_id, references(:usuario, on_delete: :delete_all), null: false
      add :post_id, references(:posts, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:likes_posts, [:usuario_id])
    create index(:likes_posts, [:post_id])
    create unique_index(:likes_posts, [:usuario_id, :post_id])
  end
end
