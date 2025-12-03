defmodule Pets.Repo.Migrations.AddRestrictConstraints do
  use Ecto.Migration

  def up do
    # Mascotas -> Raza: cambiar de :nothing a :restrict
    drop constraint(:mascotas, "mascotas_raza_id_fkey")

    alter table(:mascotas) do
      modify :raza_id, references(:razas, on_delete: :restrict)
    end

    # Mascotas -> Color: cambiar de :nothing a :restrict
    drop constraint(:mascotas, "mascotas_color_id_fkey")

    alter table(:mascotas) do
      modify :color_id, references(:colores, on_delete: :restrict)
    end

    # Mascotas -> Especie: cambiar de :nothing a :restrict
    drop constraint(:mascotas, "mascotas_especie_id_fkey")

    alter table(:mascotas) do
      modify :especie_id, references(:especies, on_delete: :restrict)
    end

    # Mensajes -> Conversacion: cambiar de :nothing a :delete_all (borrar mensajes al borrar conversación)
    drop constraint(:mensajes, "mensajes_conversacion_id_fkey")

    alter table(:mensajes) do
      modify :conversacion_id, references(:conversaciones, on_delete: :delete_all)
    end

    # Posts -> Mascota: agregar foreign key constraint (no existía)
    alter table(:posts) do
      modify :mascota_id, references(:mascotas, on_delete: :restrict)
    end
  end

  def down do
    # Revertir Mascotas -> Raza
    drop constraint(:mascotas, "mascotas_raza_id_fkey")

    alter table(:mascotas) do
      modify :raza_id, references(:razas, on_delete: :nothing)
    end

    # Revertir Mascotas -> Color
    drop constraint(:mascotas, "mascotas_color_id_fkey")

    alter table(:mascotas) do
      modify :color_id, references(:colores, on_delete: :nothing)
    end

    # Revertir Mascotas -> Especie
    drop constraint(:mascotas, "mascotas_especie_id_fkey")

    alter table(:mascotas) do
      modify :especie_id, references(:especies, on_delete: :nothing)
    end

    # Revertir Mensajes -> Conversacion
    drop constraint(:mensajes, "mensajes_conversacion_id_fkey")

    alter table(:mensajes) do
      modify :conversacion_id, references(:conversaciones, on_delete: :nothing)
    end

    # Revertir Posts -> Mascota (remover la FK)
    drop constraint(:posts, "posts_mascota_id_fkey")

    alter table(:posts) do
      modify :mascota_id, :integer
    end
  end
end
