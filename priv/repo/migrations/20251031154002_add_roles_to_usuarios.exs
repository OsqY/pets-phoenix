defmodule Pets.Repo.Migrations.AddRolesToUsuarios do
  use Ecto.Migration

  def change do
    alter table(:usuario) do
      add :roles, {:array, :string}, default: ["adoptante"]
    end
  end
end
