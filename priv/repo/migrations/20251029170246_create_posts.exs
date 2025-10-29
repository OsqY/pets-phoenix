defmodule Pets.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :content, :string
      add :fecha, :date
      add :mascota_id, :integer
      add :user_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
