defmodule Pets.AdopcionesTest do
  use Pets.DataCase

  alias Pets.Adopciones

  describe "solicitudes_adopcion" do
    alias Pets.Adopciones.SolicitudAdopcion

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.AdopcionesFixtures

    @invalid_attrs %{estado: nil, fecha_solicitud: nil, fecha_revision: nil, adoptante_id: nil, mascota_id: nil}

    test "list_solicitudes_adopcion/1 returns all scoped solicitudes_adopcion" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      solicitud_adopcion = solicitud_adopcion_fixture(scope)
      other_solicitud_adopcion = solicitud_adopcion_fixture(other_scope)
      assert Adopciones.list_solicitudes_adopcion(scope) == [solicitud_adopcion]
      assert Adopciones.list_solicitudes_adopcion(other_scope) == [other_solicitud_adopcion]
    end

    test "get_solicitud_adopcion!/2 returns the solicitud_adopcion with given id" do
      scope = usuario_scope_fixture()
      solicitud_adopcion = solicitud_adopcion_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Adopciones.get_solicitud_adopcion!(scope, solicitud_adopcion.id) == solicitud_adopcion
      assert_raise Ecto.NoResultsError, fn -> Adopciones.get_solicitud_adopcion!(other_scope, solicitud_adopcion.id) end
    end

    test "create_solicitud_adopcion/2 with valid data creates a solicitud_adopcion" do
      valid_attrs = %{estado: :pendiente, fecha_solicitud: ~D[2025-11-05], fecha_revision: ~D[2025-11-05], adoptante_id: 42, mascota_id: 42}
      scope = usuario_scope_fixture()

      assert {:ok, %SolicitudAdopcion{} = solicitud_adopcion} = Adopciones.create_solicitud_adopcion(scope, valid_attrs)
      assert solicitud_adopcion.estado == :pendiente
      assert solicitud_adopcion.fecha_solicitud == ~D[2025-11-05]
      assert solicitud_adopcion.fecha_revision == ~D[2025-11-05]
      assert solicitud_adopcion.adoptante_id == 42
      assert solicitud_adopcion.mascota_id == 42
      assert solicitud_adopcion.usuario_id == scope.usuario.id
    end

    test "create_solicitud_adopcion/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Adopciones.create_solicitud_adopcion(scope, @invalid_attrs)
    end

    test "update_solicitud_adopcion/3 with valid data updates the solicitud_adopcion" do
      scope = usuario_scope_fixture()
      solicitud_adopcion = solicitud_adopcion_fixture(scope)
      update_attrs = %{estado: :revisado, fecha_solicitud: ~D[2025-11-06], fecha_revision: ~D[2025-11-06], adoptante_id: 43, mascota_id: 43}

      assert {:ok, %SolicitudAdopcion{} = solicitud_adopcion} = Adopciones.update_solicitud_adopcion(scope, solicitud_adopcion, update_attrs)
      assert solicitud_adopcion.estado == :revisado
      assert solicitud_adopcion.fecha_solicitud == ~D[2025-11-06]
      assert solicitud_adopcion.fecha_revision == ~D[2025-11-06]
      assert solicitud_adopcion.adoptante_id == 43
      assert solicitud_adopcion.mascota_id == 43
    end

    test "update_solicitud_adopcion/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      solicitud_adopcion = solicitud_adopcion_fixture(scope)

      assert_raise MatchError, fn ->
        Adopciones.update_solicitud_adopcion(other_scope, solicitud_adopcion, %{})
      end
    end

    test "update_solicitud_adopcion/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      solicitud_adopcion = solicitud_adopcion_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Adopciones.update_solicitud_adopcion(scope, solicitud_adopcion, @invalid_attrs)
      assert solicitud_adopcion == Adopciones.get_solicitud_adopcion!(scope, solicitud_adopcion.id)
    end

    test "delete_solicitud_adopcion/2 deletes the solicitud_adopcion" do
      scope = usuario_scope_fixture()
      solicitud_adopcion = solicitud_adopcion_fixture(scope)
      assert {:ok, %SolicitudAdopcion{}} = Adopciones.delete_solicitud_adopcion(scope, solicitud_adopcion)
      assert_raise Ecto.NoResultsError, fn -> Adopciones.get_solicitud_adopcion!(scope, solicitud_adopcion.id) end
    end

    test "delete_solicitud_adopcion/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      solicitud_adopcion = solicitud_adopcion_fixture(scope)
      assert_raise MatchError, fn -> Adopciones.delete_solicitud_adopcion(other_scope, solicitud_adopcion) end
    end

    test "change_solicitud_adopcion/2 returns a solicitud_adopcion changeset" do
      scope = usuario_scope_fixture()
      solicitud_adopcion = solicitud_adopcion_fixture(scope)
      assert %Ecto.Changeset{} = Adopciones.change_solicitud_adopcion(scope, solicitud_adopcion)
    end
  end

  describe "seguimientos" do
    alias Pets.Adopciones.Seguimiento

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.AdopcionesFixtures

    @invalid_attrs %{fecha: nil, notas: nil, solicitud_id: nil, responsable_id: nil}

    test "list_seguimientos/1 returns all scoped seguimientos" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      seguimiento = seguimiento_fixture(scope)
      other_seguimiento = seguimiento_fixture(other_scope)
      assert Adopciones.list_seguimientos(scope) == [seguimiento]
      assert Adopciones.list_seguimientos(other_scope) == [other_seguimiento]
    end

    test "get_seguimiento!/2 returns the seguimiento with given id" do
      scope = usuario_scope_fixture()
      seguimiento = seguimiento_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Adopciones.get_seguimiento!(scope, seguimiento.id) == seguimiento
      assert_raise Ecto.NoResultsError, fn -> Adopciones.get_seguimiento!(other_scope, seguimiento.id) end
    end

    test "create_seguimiento/2 with valid data creates a seguimiento" do
      valid_attrs = %{fecha: ~D[2025-11-05], notas: "some notas", solicitud_id: 42, responsable_id: 42}
      scope = usuario_scope_fixture()

      assert {:ok, %Seguimiento{} = seguimiento} = Adopciones.create_seguimiento(scope, valid_attrs)
      assert seguimiento.fecha == ~D[2025-11-05]
      assert seguimiento.notas == "some notas"
      assert seguimiento.solicitud_id == 42
      assert seguimiento.responsable_id == 42
      assert seguimiento.usuario_id == scope.usuario.id
    end

    test "create_seguimiento/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Adopciones.create_seguimiento(scope, @invalid_attrs)
    end

    test "update_seguimiento/3 with valid data updates the seguimiento" do
      scope = usuario_scope_fixture()
      seguimiento = seguimiento_fixture(scope)
      update_attrs = %{fecha: ~D[2025-11-06], notas: "some updated notas", solicitud_id: 43, responsable_id: 43}

      assert {:ok, %Seguimiento{} = seguimiento} = Adopciones.update_seguimiento(scope, seguimiento, update_attrs)
      assert seguimiento.fecha == ~D[2025-11-06]
      assert seguimiento.notas == "some updated notas"
      assert seguimiento.solicitud_id == 43
      assert seguimiento.responsable_id == 43
    end

    test "update_seguimiento/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      seguimiento = seguimiento_fixture(scope)

      assert_raise MatchError, fn ->
        Adopciones.update_seguimiento(other_scope, seguimiento, %{})
      end
    end

    test "update_seguimiento/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      seguimiento = seguimiento_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Adopciones.update_seguimiento(scope, seguimiento, @invalid_attrs)
      assert seguimiento == Adopciones.get_seguimiento!(scope, seguimiento.id)
    end

    test "delete_seguimiento/2 deletes the seguimiento" do
      scope = usuario_scope_fixture()
      seguimiento = seguimiento_fixture(scope)
      assert {:ok, %Seguimiento{}} = Adopciones.delete_seguimiento(scope, seguimiento)
      assert_raise Ecto.NoResultsError, fn -> Adopciones.get_seguimiento!(scope, seguimiento.id) end
    end

    test "delete_seguimiento/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      seguimiento = seguimiento_fixture(scope)
      assert_raise MatchError, fn -> Adopciones.delete_seguimiento(other_scope, seguimiento) end
    end

    test "change_seguimiento/2 returns a seguimiento changeset" do
      scope = usuario_scope_fixture()
      seguimiento = seguimiento_fixture(scope)
      assert %Ecto.Changeset{} = Adopciones.change_seguimiento(scope, seguimiento)
    end
  end
end
