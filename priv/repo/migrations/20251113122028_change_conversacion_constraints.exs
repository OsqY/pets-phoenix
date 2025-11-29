defmodule Pets.Repo.Migrations.ChangeConversacionConstraints do
  use Ecto.Migration

  def change do
    unique_index(:conversaciones, [:emisor_id, :receptor_id],
      name: :conversaciones_emisor_id_receptor_id_unique_index
    )
  end
end
