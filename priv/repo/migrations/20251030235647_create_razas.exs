defmodule Pets.Repo.Migrations.CreateRazas do
  use Ecto.Migration

  def change do
    create table(:razas) do
      add :nombre, :string
      add :usuario_id, references(:usuario, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:razas, [:usuario_id])
  end
end
