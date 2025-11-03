defmodule Pets.Repo.Migrations.RemoveUserIdForeignKeyPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      remove :user_id
    end
  end
end
