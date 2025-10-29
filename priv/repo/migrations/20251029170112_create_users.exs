defmodule Pets.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :nombres, :string
      add :apellidos, :string
      add :correo, :string
      add :nombre_usuario, :string

      timestamps(type: :utc_datetime)
    end
  end
end
