defmodule Pets.Repo.Migrations.ChangeDonantesToDonanteInDonacionesInventario do
  use Ecto.Migration

  def change do
    alter table(:donaciones_inventario) do
      remove :donantes, {:array, :string}
      add :donante, :string
    end
  end
end
