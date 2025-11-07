defmodule Pets.RefugioTest do
  use Pets.DataCase

  alias Pets.Refugio

  describe "historiales_medicos" do
    alias Pets.Refugio.HistorialMedio

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.RefugioFixtures

    @invalid_attrs %{fecha: nil, tipo: nil, mascota_id: nil, refugio_id: nil}

    test "list_historiales_medicos/1 returns all scoped historiales_medicos" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      historial_medio = historial_medio_fixture(scope)
      other_historial_medio = historial_medio_fixture(other_scope)
      assert Refugio.list_historiales_medicos(scope) == [historial_medio]
      assert Refugio.list_historiales_medicos(other_scope) == [other_historial_medio]
    end

    test "get_historial_medio!/2 returns the historial_medio with given id" do
      scope = usuario_scope_fixture()
      historial_medio = historial_medio_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Refugio.get_historial_medio!(scope, historial_medio.id) == historial_medio
      assert_raise Ecto.NoResultsError, fn -> Refugio.get_historial_medio!(other_scope, historial_medio.id) end
    end

    test "create_historial_medio/2 with valid data creates a historial_medio" do
      valid_attrs = %{fecha: ~D[2025-11-04], tipo: :vacuna, mascota_id: 42, refugio_id: 42}
      scope = usuario_scope_fixture()

      assert {:ok, %HistorialMedio{} = historial_medio} = Refugio.create_historial_medio(scope, valid_attrs)
      assert historial_medio.fecha == ~D[2025-11-04]
      assert historial_medio.tipo == :vacuna
      assert historial_medio.mascota_id == 42
      assert historial_medio.refugio_id == 42
      assert historial_medio.usuario_id == scope.usuario.id
    end

    test "create_historial_medio/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Refugio.create_historial_medio(scope, @invalid_attrs)
    end

    test "update_historial_medio/3 with valid data updates the historial_medio" do
      scope = usuario_scope_fixture()
      historial_medio = historial_medio_fixture(scope)
      update_attrs = %{fecha: ~D[2025-11-05], tipo: :tratamiento, mascota_id: 43, refugio_id: 43}

      assert {:ok, %HistorialMedio{} = historial_medio} = Refugio.update_historial_medio(scope, historial_medio, update_attrs)
      assert historial_medio.fecha == ~D[2025-11-05]
      assert historial_medio.tipo == :tratamiento
      assert historial_medio.mascota_id == 43
      assert historial_medio.refugio_id == 43
    end

    test "update_historial_medio/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      historial_medio = historial_medio_fixture(scope)

      assert_raise MatchError, fn ->
        Refugio.update_historial_medio(other_scope, historial_medio, %{})
      end
    end

    test "update_historial_medio/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      historial_medio = historial_medio_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Refugio.update_historial_medio(scope, historial_medio, @invalid_attrs)
      assert historial_medio == Refugio.get_historial_medio!(scope, historial_medio.id)
    end

    test "delete_historial_medio/2 deletes the historial_medio" do
      scope = usuario_scope_fixture()
      historial_medio = historial_medio_fixture(scope)
      assert {:ok, %HistorialMedio{}} = Refugio.delete_historial_medio(scope, historial_medio)
      assert_raise Ecto.NoResultsError, fn -> Refugio.get_historial_medio!(scope, historial_medio.id) end
    end

    test "delete_historial_medio/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      historial_medio = historial_medio_fixture(scope)
      assert_raise MatchError, fn -> Refugio.delete_historial_medio(other_scope, historial_medio) end
    end

    test "change_historial_medio/2 returns a historial_medio changeset" do
      scope = usuario_scope_fixture()
      historial_medio = historial_medio_fixture(scope)
      assert %Ecto.Changeset{} = Refugio.change_historial_medio(scope, historial_medio)
    end
  end
end
