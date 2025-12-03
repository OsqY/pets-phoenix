defmodule Pets.Repo.Migrations.ChangeDonantesToDonanteInDonacionesDinero do
  use Ecto.Migration

  def change do
    alter table(:donaciones_dinero) do
      remove :donantes, {:array, :string}
      add :donante, :string
    end
  end
end
