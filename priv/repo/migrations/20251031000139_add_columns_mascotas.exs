defmodule Pets.Repo.Migrations.AddColumnsToMascotas do
  use Ecto.Migration

  def change do
    alter table(:mascotas) do
      add :sexo, :string
      add :tamanio, :string
      add :historia, :string
      add :estado, :string
      add :energia, :string
      add :sociable_mascotas, :boolean
      add :sociable_personas, :boolean
      add :necesidades_especiales, :string
      add :color_id, references(:colores, type: :id, on_delete: :nothing)
      add :especie_id, references(:especies, type: :id, on_delete: :nothing)
      add :raza_id, references(:razas, type: :id, on_delete: :nothing)
      add :refugio_id, references(:usuario, type: :id, on_delete: :nothing), null: false
    end
  end
end
