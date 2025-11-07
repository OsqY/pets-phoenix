defmodule Pets.Repo.Migrations.CreateDonacionesDinero do
  use Ecto.Migration

  def change do
    create table(:donaciones_dinero) do
      add :monto, :float
      add :descripcion, :string
      add :fecha, :date
      add :donantes, {:array, :string}
      add :refugio_id, references(:usuario, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:donaciones_dinero, [:refugio_id])
  end
end
