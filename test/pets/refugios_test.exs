defmodule Pets.RefugiosTest do
  use Pets.DataCase

  alias Pets.Refugios

  describe "items_inventario" do
    alias Pets.Refugios.ItemInventario

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.RefugiosFixtures

    @invalid_attrs %{nombre: nil, descripcion: nil, cantidad: nil, medida: nil, tipo: nil, refugio_id: nil}

    test "list_items_inventario/1 returns all scoped items_inventario" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      other_item_inventario = item_inventario_fixture(other_scope)
      assert Refugios.list_items_inventario(scope) == [item_inventario]
      assert Refugios.list_items_inventario(other_scope) == [other_item_inventario]
    end

    test "get_item_inventario!/2 returns the item_inventario with given id" do
      scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Refugios.get_item_inventario!(scope, item_inventario.id) == item_inventario
      assert_raise Ecto.NoResultsError, fn -> Refugios.get_item_inventario!(other_scope, item_inventario.id) end
    end

    test "create_item_inventario/2 with valid data creates a item_inventario" do
      valid_attrs = %{nombre: "some nombre", descripcion: "some descripcion", cantidad: 120.5, medida: "some medida", tipo: "some tipo", refugio_id: 42}
      scope = usuario_scope_fixture()

      assert {:ok, %ItemInventario{} = item_inventario} = Refugios.create_item_inventario(scope, valid_attrs)
      assert item_inventario.nombre == "some nombre"
      assert item_inventario.descripcion == "some descripcion"
      assert item_inventario.cantidad == 120.5
      assert item_inventario.medida == "some medida"
      assert item_inventario.tipo == "some tipo"
      assert item_inventario.refugio_id == 42
      assert item_inventario.usuario_id == scope.usuario.id
    end

    test "create_item_inventario/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Refugios.create_item_inventario(scope, @invalid_attrs)
    end

    test "update_item_inventario/3 with valid data updates the item_inventario" do
      scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      update_attrs = %{nombre: "some updated nombre", descripcion: "some updated descripcion", cantidad: 456.7, medida: "some updated medida", tipo: "some updated tipo", refugio_id: 43}

      assert {:ok, %ItemInventario{} = item_inventario} = Refugios.update_item_inventario(scope, item_inventario, update_attrs)
      assert item_inventario.nombre == "some updated nombre"
      assert item_inventario.descripcion == "some updated descripcion"
      assert item_inventario.cantidad == 456.7
      assert item_inventario.medida == "some updated medida"
      assert item_inventario.tipo == "some updated tipo"
      assert item_inventario.refugio_id == 43
    end

    test "update_item_inventario/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)

      assert_raise MatchError, fn ->
        Refugios.update_item_inventario(other_scope, item_inventario, %{})
      end
    end

    test "update_item_inventario/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Refugios.update_item_inventario(scope, item_inventario, @invalid_attrs)
      assert item_inventario == Refugios.get_item_inventario!(scope, item_inventario.id)
    end

    test "delete_item_inventario/2 deletes the item_inventario" do
      scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      assert {:ok, %ItemInventario{}} = Refugios.delete_item_inventario(scope, item_inventario)
      assert_raise Ecto.NoResultsError, fn -> Refugios.get_item_inventario!(scope, item_inventario.id) end
    end

    test "delete_item_inventario/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      assert_raise MatchError, fn -> Refugios.delete_item_inventario(other_scope, item_inventario) end
    end

    test "change_item_inventario/2 returns a item_inventario changeset" do
      scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      assert %Ecto.Changeset{} = Refugios.change_item_inventario(scope, item_inventario)
    end
  end

  describe "items_inventario" do
    alias Pets.Refugios.ItemInventario

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.RefugiosFixtures

    @invalid_attrs %{nombre: nil, descripcion: nil, cantidad: nil, refugio_id: nil, medida: nil, tipo: nil}

    test "list_items_inventario/1 returns all scoped items_inventario" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      other_item_inventario = item_inventario_fixture(other_scope)
      assert Refugios.list_items_inventario(scope) == [item_inventario]
      assert Refugios.list_items_inventario(other_scope) == [other_item_inventario]
    end

    test "get_item_inventario!/2 returns the item_inventario with given id" do
      scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Refugios.get_item_inventario!(scope, item_inventario.id) == item_inventario
      assert_raise Ecto.NoResultsError, fn -> Refugios.get_item_inventario!(other_scope, item_inventario.id) end
    end

    test "create_item_inventario/2 with valid data creates a item_inventario" do
      valid_attrs = %{nombre: "some nombre", descripcion: "some descripcion", cantidad: 120.5, refugio_id: 42, medida: :unidades, tipo: :comida}
      scope = usuario_scope_fixture()

      assert {:ok, %ItemInventario{} = item_inventario} = Refugios.create_item_inventario(scope, valid_attrs)
      assert item_inventario.nombre == "some nombre"
      assert item_inventario.descripcion == "some descripcion"
      assert item_inventario.cantidad == 120.5
      assert item_inventario.refugio_id == 42
      assert item_inventario.medida == :unidades
      assert item_inventario.tipo == :comida
      assert item_inventario.usuario_id == scope.usuario.id
    end

    test "create_item_inventario/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Refugios.create_item_inventario(scope, @invalid_attrs)
    end

    test "update_item_inventario/3 with valid data updates the item_inventario" do
      scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      update_attrs = %{nombre: "some updated nombre", descripcion: "some updated descripcion", cantidad: 456.7, refugio_id: 43, medida: :kg, tipo: :medicina}

      assert {:ok, %ItemInventario{} = item_inventario} = Refugios.update_item_inventario(scope, item_inventario, update_attrs)
      assert item_inventario.nombre == "some updated nombre"
      assert item_inventario.descripcion == "some updated descripcion"
      assert item_inventario.cantidad == 456.7
      assert item_inventario.refugio_id == 43
      assert item_inventario.medida == :kg
      assert item_inventario.tipo == :medicina
    end

    test "update_item_inventario/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)

      assert_raise MatchError, fn ->
        Refugios.update_item_inventario(other_scope, item_inventario, %{})
      end
    end

    test "update_item_inventario/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Refugios.update_item_inventario(scope, item_inventario, @invalid_attrs)
      assert item_inventario == Refugios.get_item_inventario!(scope, item_inventario.id)
    end

    test "delete_item_inventario/2 deletes the item_inventario" do
      scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      assert {:ok, %ItemInventario{}} = Refugios.delete_item_inventario(scope, item_inventario)
      assert_raise Ecto.NoResultsError, fn -> Refugios.get_item_inventario!(scope, item_inventario.id) end
    end

    test "delete_item_inventario/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      assert_raise MatchError, fn -> Refugios.delete_item_inventario(other_scope, item_inventario) end
    end

    test "change_item_inventario/2 returns a item_inventario changeset" do
      scope = usuario_scope_fixture()
      item_inventario = item_inventario_fixture(scope)
      assert %Ecto.Changeset{} = Refugios.change_item_inventario(scope, item_inventario)
    end
  end

  describe "donaciones_dinero" do
    alias Pets.Refugios.DonacionDinero

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.RefugiosFixtures

    @invalid_attrs %{monto: nil, descripcion: nil, fecha: nil, donantes: nil, refugio_id: nil}

    test "list_donaciones_dinero/1 returns all scoped donaciones_dinero" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      donacion_dinero = donacion_dinero_fixture(scope)
      other_donacion_dinero = donacion_dinero_fixture(other_scope)
      assert Refugios.list_donaciones_dinero(scope) == [donacion_dinero]
      assert Refugios.list_donaciones_dinero(other_scope) == [other_donacion_dinero]
    end

    test "get_donacion_dinero!/2 returns the donacion_dinero with given id" do
      scope = usuario_scope_fixture()
      donacion_dinero = donacion_dinero_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Refugios.get_donacion_dinero!(scope, donacion_dinero.id) == donacion_dinero
      assert_raise Ecto.NoResultsError, fn -> Refugios.get_donacion_dinero!(other_scope, donacion_dinero.id) end
    end

    test "create_donacion_dinero/2 with valid data creates a donacion_dinero" do
      valid_attrs = %{monto: 120.5, descripcion: "some descripcion", fecha: ~D[2025-11-03], donantes: ["option1", "option2"], refugio_id: 42}
      scope = usuario_scope_fixture()

      assert {:ok, %DonacionDinero{} = donacion_dinero} = Refugios.create_donacion_dinero(scope, valid_attrs)
      assert donacion_dinero.monto == 120.5
      assert donacion_dinero.descripcion == "some descripcion"
      assert donacion_dinero.fecha == ~D[2025-11-03]
      assert donacion_dinero.donantes == ["option1", "option2"]
      assert donacion_dinero.refugio_id == 42
      assert donacion_dinero.usuario_id == scope.usuario.id
    end

    test "create_donacion_dinero/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Refugios.create_donacion_dinero(scope, @invalid_attrs)
    end

    test "update_donacion_dinero/3 with valid data updates the donacion_dinero" do
      scope = usuario_scope_fixture()
      donacion_dinero = donacion_dinero_fixture(scope)
      update_attrs = %{monto: 456.7, descripcion: "some updated descripcion", fecha: ~D[2025-11-04], donantes: ["option1"], refugio_id: 43}

      assert {:ok, %DonacionDinero{} = donacion_dinero} = Refugios.update_donacion_dinero(scope, donacion_dinero, update_attrs)
      assert donacion_dinero.monto == 456.7
      assert donacion_dinero.descripcion == "some updated descripcion"
      assert donacion_dinero.fecha == ~D[2025-11-04]
      assert donacion_dinero.donantes == ["option1"]
      assert donacion_dinero.refugio_id == 43
    end

    test "update_donacion_dinero/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      donacion_dinero = donacion_dinero_fixture(scope)

      assert_raise MatchError, fn ->
        Refugios.update_donacion_dinero(other_scope, donacion_dinero, %{})
      end
    end

    test "update_donacion_dinero/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      donacion_dinero = donacion_dinero_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Refugios.update_donacion_dinero(scope, donacion_dinero, @invalid_attrs)
      assert donacion_dinero == Refugios.get_donacion_dinero!(scope, donacion_dinero.id)
    end

    test "delete_donacion_dinero/2 deletes the donacion_dinero" do
      scope = usuario_scope_fixture()
      donacion_dinero = donacion_dinero_fixture(scope)
      assert {:ok, %DonacionDinero{}} = Refugios.delete_donacion_dinero(scope, donacion_dinero)
      assert_raise Ecto.NoResultsError, fn -> Refugios.get_donacion_dinero!(scope, donacion_dinero.id) end
    end

    test "delete_donacion_dinero/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      donacion_dinero = donacion_dinero_fixture(scope)
      assert_raise MatchError, fn -> Refugios.delete_donacion_dinero(other_scope, donacion_dinero) end
    end

    test "change_donacion_dinero/2 returns a donacion_dinero changeset" do
      scope = usuario_scope_fixture()
      donacion_dinero = donacion_dinero_fixture(scope)
      assert %Ecto.Changeset{} = Refugios.change_donacion_dinero(scope, donacion_dinero)
    end
  end

  describe "donaciones_inventario" do
    alias Pets.Refugios.DonacionInventario

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.RefugiosFixtures

    @invalid_attrs %{cantidad: nil, descripcion: nil, fecha: nil, donantes: nil, refugio_id: nil, medida: nil, tipo: nil}

    test "list_donaciones_inventario/1 returns all scoped donaciones_inventario" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      donacion_inventario = donacion_inventario_fixture(scope)
      other_donacion_inventario = donacion_inventario_fixture(other_scope)
      assert Refugios.list_donaciones_inventario(scope) == [donacion_inventario]
      assert Refugios.list_donaciones_inventario(other_scope) == [other_donacion_inventario]
    end

    test "get_donacion_inventario!/2 returns the donacion_inventario with given id" do
      scope = usuario_scope_fixture()
      donacion_inventario = donacion_inventario_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Refugios.get_donacion_inventario!(scope, donacion_inventario.id) == donacion_inventario
      assert_raise Ecto.NoResultsError, fn -> Refugios.get_donacion_inventario!(other_scope, donacion_inventario.id) end
    end

    test "create_donacion_inventario/2 with valid data creates a donacion_inventario" do
      valid_attrs = %{cantidad: 120.5, descripcion: "some descripcion", fecha: ~D[2025-11-03], donantes: ["option1", "option2"], refugio_id: 42, medida: :unidades, tipo: :comida}
      scope = usuario_scope_fixture()

      assert {:ok, %DonacionInventario{} = donacion_inventario} = Refugios.create_donacion_inventario(scope, valid_attrs)
      assert donacion_inventario.cantidad == 120.5
      assert donacion_inventario.descripcion == "some descripcion"
      assert donacion_inventario.fecha == ~D[2025-11-03]
      assert donacion_inventario.donantes == ["option1", "option2"]
      assert donacion_inventario.refugio_id == 42
      assert donacion_inventario.medida == :unidades
      assert donacion_inventario.tipo == :comida
      assert donacion_inventario.usuario_id == scope.usuario.id
    end

    test "create_donacion_inventario/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Refugios.create_donacion_inventario(scope, @invalid_attrs)
    end

    test "update_donacion_inventario/3 with valid data updates the donacion_inventario" do
      scope = usuario_scope_fixture()
      donacion_inventario = donacion_inventario_fixture(scope)
      update_attrs = %{cantidad: 456.7, descripcion: "some updated descripcion", fecha: ~D[2025-11-04], donantes: ["option1"], refugio_id: 43, medida: :kg, tipo: :medicina}

      assert {:ok, %DonacionInventario{} = donacion_inventario} = Refugios.update_donacion_inventario(scope, donacion_inventario, update_attrs)
      assert donacion_inventario.cantidad == 456.7
      assert donacion_inventario.descripcion == "some updated descripcion"
      assert donacion_inventario.fecha == ~D[2025-11-04]
      assert donacion_inventario.donantes == ["option1"]
      assert donacion_inventario.refugio_id == 43
      assert donacion_inventario.medida == :kg
      assert donacion_inventario.tipo == :medicina
    end

    test "update_donacion_inventario/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      donacion_inventario = donacion_inventario_fixture(scope)

      assert_raise MatchError, fn ->
        Refugios.update_donacion_inventario(other_scope, donacion_inventario, %{})
      end
    end

    test "update_donacion_inventario/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      donacion_inventario = donacion_inventario_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Refugios.update_donacion_inventario(scope, donacion_inventario, @invalid_attrs)
      assert donacion_inventario == Refugios.get_donacion_inventario!(scope, donacion_inventario.id)
    end

    test "delete_donacion_inventario/2 deletes the donacion_inventario" do
      scope = usuario_scope_fixture()
      donacion_inventario = donacion_inventario_fixture(scope)
      assert {:ok, %DonacionInventario{}} = Refugios.delete_donacion_inventario(scope, donacion_inventario)
      assert_raise Ecto.NoResultsError, fn -> Refugios.get_donacion_inventario!(scope, donacion_inventario.id) end
    end

    test "delete_donacion_inventario/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      donacion_inventario = donacion_inventario_fixture(scope)
      assert_raise MatchError, fn -> Refugios.delete_donacion_inventario(other_scope, donacion_inventario) end
    end

    test "change_donacion_inventario/2 returns a donacion_inventario changeset" do
      scope = usuario_scope_fixture()
      donacion_inventario = donacion_inventario_fixture(scope)
      assert %Ecto.Changeset{} = Refugios.change_donacion_inventario(scope, donacion_inventario)
    end
  end
end
