defmodule Pets.Repo.Migrations.ChangeValuesMascotas do
  use Ecto.Migration

  def change do
    alter table(:mascotas) do
      modify :historia, :text, null: true
      modify :necesidades_especiales, :text, null: true
      modify :refugio_id, :id, null: true
    end
  end
end
