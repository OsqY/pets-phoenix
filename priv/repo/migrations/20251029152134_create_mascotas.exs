defmodule Pets.Repo.Migrations.CreateMascotas do
  use Ecto.Migration

  def change do
    create table(:mascotas) do
      add :nombre, :string
      add :descripcion, :text
      add :edad, :integer
      add :peso, :float

      timestamps(type: :utc_datetime)
    end
  end
end
