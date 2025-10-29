defmodule Pets.Repo.Migrations.CreateUsuarioAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:usuario) do
      add :email, :citext, null: false
      add :hashed_password, :string
      add :confirmed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:usuario, [:email])

    create table(:usuario_tokens) do
      add :usuario_id, references(:usuario, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      add :authenticated_at, :utc_datetime

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:usuario_tokens, [:usuario_id])
    create unique_index(:usuario_tokens, [:context, :token])
  end
end
