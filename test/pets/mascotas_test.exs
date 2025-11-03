defmodule Pets.MascotasTest do
  use Pets.DataCase

  alias Pets.Mascotas

  describe "mascotas" do
    alias Pets.Mascotas.Mascota

    import Pets.MascotasFixtures

    @invalid_attrs %{nombre: nil, descripcion: nil, edad: nil, peso: nil}

    test "list_mascotas/0 returns all mascotas" do
      mascota = mascota_fixture()
      assert Mascotas.list_mascotas() == [mascota]
    end

    test "get_mascota!/1 returns the mascota with given id" do
      mascota = mascota_fixture()
      assert Mascotas.get_mascota!(mascota.id) == mascota
    end

    test "create_mascota/1 with valid data creates a mascota" do
      valid_attrs = %{nombre: "some nombre", descripcion: "some descripcion", edad: 42, peso: 120.5}

      assert {:ok, %Mascota{} = mascota} = Mascotas.create_mascota(valid_attrs)
      assert mascota.nombre == "some nombre"
      assert mascota.descripcion == "some descripcion"
      assert mascota.edad == 42
      assert mascota.peso == 120.5
    end

    test "create_mascota/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mascotas.create_mascota(@invalid_attrs)
    end

    test "update_mascota/2 with valid data updates the mascota" do
      mascota = mascota_fixture()
      update_attrs = %{nombre: "some updated nombre", descripcion: "some updated descripcion", edad: 43, peso: 456.7}

      assert {:ok, %Mascota{} = mascota} = Mascotas.update_mascota(mascota, update_attrs)
      assert mascota.nombre == "some updated nombre"
      assert mascota.descripcion == "some updated descripcion"
      assert mascota.edad == 43
      assert mascota.peso == 456.7
    end

    test "update_mascota/2 with invalid data returns error changeset" do
      mascota = mascota_fixture()
      assert {:error, %Ecto.Changeset{}} = Mascotas.update_mascota(mascota, @invalid_attrs)
      assert mascota == Mascotas.get_mascota!(mascota.id)
    end

    test "delete_mascota/1 deletes the mascota" do
      mascota = mascota_fixture()
      assert {:ok, %Mascota{}} = Mascotas.delete_mascota(mascota)
      assert_raise Ecto.NoResultsError, fn -> Mascotas.get_mascota!(mascota.id) end
    end

    test "change_mascota/1 returns a mascota changeset" do
      mascota = mascota_fixture()
      assert %Ecto.Changeset{} = Mascotas.change_mascota(mascota)
    end
  end

  describe "razas" do
    alias Pets.Mascotas.Raza

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.MascotasFixtures

    @invalid_attrs %{nombre: nil}

    test "list_razas/1 returns all scoped razas" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      raza = raza_fixture(scope)
      other_raza = raza_fixture(other_scope)
      assert Mascotas.list_razas(scope) == [raza]
      assert Mascotas.list_razas(other_scope) == [other_raza]
    end

    test "get_raza!/2 returns the raza with given id" do
      scope = usuario_scope_fixture()
      raza = raza_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Mascotas.get_raza!(scope, raza.id) == raza
      assert_raise Ecto.NoResultsError, fn -> Mascotas.get_raza!(other_scope, raza.id) end
    end

    test "create_raza/2 with valid data creates a raza" do
      valid_attrs = %{nombre: "some nombre"}
      scope = usuario_scope_fixture()

      assert {:ok, %Raza{} = raza} = Mascotas.create_raza(scope, valid_attrs)
      assert raza.nombre == "some nombre"
      assert raza.usuario_id == scope.usuario.id
    end

    test "create_raza/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Mascotas.create_raza(scope, @invalid_attrs)
    end

    test "update_raza/3 with valid data updates the raza" do
      scope = usuario_scope_fixture()
      raza = raza_fixture(scope)
      update_attrs = %{nombre: "some updated nombre"}

      assert {:ok, %Raza{} = raza} = Mascotas.update_raza(scope, raza, update_attrs)
      assert raza.nombre == "some updated nombre"
    end

    test "update_raza/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      raza = raza_fixture(scope)

      assert_raise MatchError, fn ->
        Mascotas.update_raza(other_scope, raza, %{})
      end
    end

    test "update_raza/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      raza = raza_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Mascotas.update_raza(scope, raza, @invalid_attrs)
      assert raza == Mascotas.get_raza!(scope, raza.id)
    end

    test "delete_raza/2 deletes the raza" do
      scope = usuario_scope_fixture()
      raza = raza_fixture(scope)
      assert {:ok, %Raza{}} = Mascotas.delete_raza(scope, raza)
      assert_raise Ecto.NoResultsError, fn -> Mascotas.get_raza!(scope, raza.id) end
    end

    test "delete_raza/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      raza = raza_fixture(scope)
      assert_raise MatchError, fn -> Mascotas.delete_raza(other_scope, raza) end
    end

    test "change_raza/2 returns a raza changeset" do
      scope = usuario_scope_fixture()
      raza = raza_fixture(scope)
      assert %Ecto.Changeset{} = Mascotas.change_raza(scope, raza)
    end
  end

  describe "especies" do
    alias Pets.Mascotas.Especie

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.MascotasFixtures

    @invalid_attrs %{nombre: nil}

    test "list_especies/1 returns all scoped especies" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      especie = especie_fixture(scope)
      other_especie = especie_fixture(other_scope)
      assert Mascotas.list_especies(scope) == [especie]
      assert Mascotas.list_especies(other_scope) == [other_especie]
    end

    test "get_especie!/2 returns the especie with given id" do
      scope = usuario_scope_fixture()
      especie = especie_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Mascotas.get_especie!(scope, especie.id) == especie
      assert_raise Ecto.NoResultsError, fn -> Mascotas.get_especie!(other_scope, especie.id) end
    end

    test "create_especie/2 with valid data creates a especie" do
      valid_attrs = %{nombre: "some nombre"}
      scope = usuario_scope_fixture()

      assert {:ok, %Especie{} = especie} = Mascotas.create_especie(scope, valid_attrs)
      assert especie.nombre == "some nombre"
      assert especie.usuario_id == scope.usuario.id
    end

    test "create_especie/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Mascotas.create_especie(scope, @invalid_attrs)
    end

    test "update_especie/3 with valid data updates the especie" do
      scope = usuario_scope_fixture()
      especie = especie_fixture(scope)
      update_attrs = %{nombre: "some updated nombre"}

      assert {:ok, %Especie{} = especie} = Mascotas.update_especie(scope, especie, update_attrs)
      assert especie.nombre == "some updated nombre"
    end

    test "update_especie/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      especie = especie_fixture(scope)

      assert_raise MatchError, fn ->
        Mascotas.update_especie(other_scope, especie, %{})
      end
    end

    test "update_especie/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      especie = especie_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Mascotas.update_especie(scope, especie, @invalid_attrs)
      assert especie == Mascotas.get_especie!(scope, especie.id)
    end

    test "delete_especie/2 deletes the especie" do
      scope = usuario_scope_fixture()
      especie = especie_fixture(scope)
      assert {:ok, %Especie{}} = Mascotas.delete_especie(scope, especie)
      assert_raise Ecto.NoResultsError, fn -> Mascotas.get_especie!(scope, especie.id) end
    end

    test "delete_especie/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      especie = especie_fixture(scope)
      assert_raise MatchError, fn -> Mascotas.delete_especie(other_scope, especie) end
    end

    test "change_especie/2 returns a especie changeset" do
      scope = usuario_scope_fixture()
      especie = especie_fixture(scope)
      assert %Ecto.Changeset{} = Mascotas.change_especie(scope, especie)
    end
  end

  describe "colores" do
    alias Pets.Mascotas.Color

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.MascotasFixtures

    @invalid_attrs %{nombre: nil, especie_id: nil}

    test "list_colores/1 returns all scoped colores" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      color = color_fixture(scope)
      other_color = color_fixture(other_scope)
      assert Mascotas.list_colores(scope) == [color]
      assert Mascotas.list_colores(other_scope) == [other_color]
    end

    test "get_color!/2 returns the color with given id" do
      scope = usuario_scope_fixture()
      color = color_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Mascotas.get_color!(scope, color.id) == color
      assert_raise Ecto.NoResultsError, fn -> Mascotas.get_color!(other_scope, color.id) end
    end

    test "create_color/2 with valid data creates a color" do
      valid_attrs = %{nombre: "some nombre", especie_id: 42}
      scope = usuario_scope_fixture()

      assert {:ok, %Color{} = color} = Mascotas.create_color(scope, valid_attrs)
      assert color.nombre == "some nombre"
      assert color.especie_id == 42
      assert color.usuario_id == scope.usuario.id
    end

    test "create_color/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Mascotas.create_color(scope, @invalid_attrs)
    end

    test "update_color/3 with valid data updates the color" do
      scope = usuario_scope_fixture()
      color = color_fixture(scope)
      update_attrs = %{nombre: "some updated nombre", especie_id: 43}

      assert {:ok, %Color{} = color} = Mascotas.update_color(scope, color, update_attrs)
      assert color.nombre == "some updated nombre"
      assert color.especie_id == 43
    end

    test "update_color/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      color = color_fixture(scope)

      assert_raise MatchError, fn ->
        Mascotas.update_color(other_scope, color, %{})
      end
    end

    test "update_color/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      color = color_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Mascotas.update_color(scope, color, @invalid_attrs)
      assert color == Mascotas.get_color!(scope, color.id)
    end

    test "delete_color/2 deletes the color" do
      scope = usuario_scope_fixture()
      color = color_fixture(scope)
      assert {:ok, %Color{}} = Mascotas.delete_color(scope, color)
      assert_raise Ecto.NoResultsError, fn -> Mascotas.get_color!(scope, color.id) end
    end

    test "delete_color/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      color = color_fixture(scope)
      assert_raise MatchError, fn -> Mascotas.delete_color(other_scope, color) end
    end

    test "change_color/2 returns a color changeset" do
      scope = usuario_scope_fixture()
      color = color_fixture(scope)
      assert %Ecto.Changeset{} = Mascotas.change_color(scope, color)
    end
  end

  describe "mascotas" do
    alias Pets.Mascotas.Mascota

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.MascotasFixtures

    @invalid_attrs %{usuario_id: nil, nombre: nil, descripcion: nil, edad: nil, sexo: nil, tamanio: nil, peso: nil, color_id: nil, especie_id: nil, raza_id: nil}

    test "list_mascotas/1 returns all scoped mascotas" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      mascota = mascota_fixture(scope)
      other_mascota = mascota_fixture(other_scope)
      assert Mascotas.list_mascotas(scope) == [mascota]
      assert Mascotas.list_mascotas(other_scope) == [other_mascota]
    end

    test "get_mascota!/2 returns the mascota with given id" do
      scope = usuario_scope_fixture()
      mascota = mascota_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Mascotas.get_mascota!(scope, mascota.id) == mascota
      assert_raise Ecto.NoResultsError, fn -> Mascotas.get_mascota!(other_scope, mascota.id) end
    end

    test "create_mascota/2 with valid data creates a mascota" do
      valid_attrs = %{usuario_id: 42, nombre: "some nombre", descripcion: "some descripcion", edad: 42, sexo: "some sexo", tamanio: "some tamanio", peso: 120.5, color_id: 42, especie_id: 42, raza_id: 42}
      scope = usuario_scope_fixture()

      assert {:ok, %Mascota{} = mascota} = Mascotas.create_mascota(scope, valid_attrs)
      assert mascota.usuario_id == 42
      assert mascota.nombre == "some nombre"
      assert mascota.descripcion == "some descripcion"
      assert mascota.edad == 42
      assert mascota.sexo == "some sexo"
      assert mascota.tamanio == "some tamanio"
      assert mascota.peso == 120.5
      assert mascota.color_id == 42
      assert mascota.especie_id == 42
      assert mascota.raza_id == 42
      assert mascota.usuario_id == scope.usuario.id
    end

    test "create_mascota/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Mascotas.create_mascota(scope, @invalid_attrs)
    end

    test "update_mascota/3 with valid data updates the mascota" do
      scope = usuario_scope_fixture()
      mascota = mascota_fixture(scope)
      update_attrs = %{usuario_id: 43, nombre: "some updated nombre", descripcion: "some updated descripcion", edad: 43, sexo: "some updated sexo", tamanio: "some updated tamanio", peso: 456.7, color_id: 43, especie_id: 43, raza_id: 43}

      assert {:ok, %Mascota{} = mascota} = Mascotas.update_mascota(scope, mascota, update_attrs)
      assert mascota.usuario_id == 43
      assert mascota.nombre == "some updated nombre"
      assert mascota.descripcion == "some updated descripcion"
      assert mascota.edad == 43
      assert mascota.sexo == "some updated sexo"
      assert mascota.tamanio == "some updated tamanio"
      assert mascota.peso == 456.7
      assert mascota.color_id == 43
      assert mascota.especie_id == 43
      assert mascota.raza_id == 43
    end

    test "update_mascota/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      mascota = mascota_fixture(scope)

      assert_raise MatchError, fn ->
        Mascotas.update_mascota(other_scope, mascota, %{})
      end
    end

    test "update_mascota/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      mascota = mascota_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Mascotas.update_mascota(scope, mascota, @invalid_attrs)
      assert mascota == Mascotas.get_mascota!(scope, mascota.id)
    end

    test "delete_mascota/2 deletes the mascota" do
      scope = usuario_scope_fixture()
      mascota = mascota_fixture(scope)
      assert {:ok, %Mascota{}} = Mascotas.delete_mascota(scope, mascota)
      assert_raise Ecto.NoResultsError, fn -> Mascotas.get_mascota!(scope, mascota.id) end
    end

    test "delete_mascota/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      mascota = mascota_fixture(scope)
      assert_raise MatchError, fn -> Mascotas.delete_mascota(other_scope, mascota) end
    end

    test "change_mascota/2 returns a mascota changeset" do
      scope = usuario_scope_fixture()
      mascota = mascota_fixture(scope)
      assert %Ecto.Changeset{} = Mascotas.change_mascota(scope, mascota)
    end
  end

  describe "imagenes_mascotas" do
    alias Pets.Mascotas.ImagenMascota

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.MascotasFixtures

    @invalid_attrs %{url: nil, mascota_id: nil}

    test "list_imagenes_mascotas/1 returns all scoped imagenes_mascotas" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      imagen_mascota = imagen_mascota_fixture(scope)
      other_imagen_mascota = imagen_mascota_fixture(other_scope)
      assert Mascotas.list_imagenes_mascotas(scope) == [imagen_mascota]
      assert Mascotas.list_imagenes_mascotas(other_scope) == [other_imagen_mascota]
    end

    test "get_imagen_mascota!/2 returns the imagen_mascota with given id" do
      scope = usuario_scope_fixture()
      imagen_mascota = imagen_mascota_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Mascotas.get_imagen_mascota!(scope, imagen_mascota.id) == imagen_mascota
      assert_raise Ecto.NoResultsError, fn -> Mascotas.get_imagen_mascota!(other_scope, imagen_mascota.id) end
    end

    test "create_imagen_mascota/2 with valid data creates a imagen_mascota" do
      valid_attrs = %{url: "some url", mascota_id: 42}
      scope = usuario_scope_fixture()

      assert {:ok, %ImagenMascota{} = imagen_mascota} = Mascotas.create_imagen_mascota(scope, valid_attrs)
      assert imagen_mascota.url == "some url"
      assert imagen_mascota.mascota_id == 42
      assert imagen_mascota.usuario_id == scope.usuario.id
    end

    test "create_imagen_mascota/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Mascotas.create_imagen_mascota(scope, @invalid_attrs)
    end

    test "update_imagen_mascota/3 with valid data updates the imagen_mascota" do
      scope = usuario_scope_fixture()
      imagen_mascota = imagen_mascota_fixture(scope)
      update_attrs = %{url: "some updated url", mascota_id: 43}

      assert {:ok, %ImagenMascota{} = imagen_mascota} = Mascotas.update_imagen_mascota(scope, imagen_mascota, update_attrs)
      assert imagen_mascota.url == "some updated url"
      assert imagen_mascota.mascota_id == 43
    end

    test "update_imagen_mascota/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      imagen_mascota = imagen_mascota_fixture(scope)

      assert_raise MatchError, fn ->
        Mascotas.update_imagen_mascota(other_scope, imagen_mascota, %{})
      end
    end

    test "update_imagen_mascota/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      imagen_mascota = imagen_mascota_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Mascotas.update_imagen_mascota(scope, imagen_mascota, @invalid_attrs)
      assert imagen_mascota == Mascotas.get_imagen_mascota!(scope, imagen_mascota.id)
    end

    test "delete_imagen_mascota/2 deletes the imagen_mascota" do
      scope = usuario_scope_fixture()
      imagen_mascota = imagen_mascota_fixture(scope)
      assert {:ok, %ImagenMascota{}} = Mascotas.delete_imagen_mascota(scope, imagen_mascota)
      assert_raise Ecto.NoResultsError, fn -> Mascotas.get_imagen_mascota!(scope, imagen_mascota.id) end
    end

    test "delete_imagen_mascota/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      imagen_mascota = imagen_mascota_fixture(scope)
      assert_raise MatchError, fn -> Mascotas.delete_imagen_mascota(other_scope, imagen_mascota) end
    end

    test "change_imagen_mascota/2 returns a imagen_mascota changeset" do
      scope = usuario_scope_fixture()
      imagen_mascota = imagen_mascota_fixture(scope)
      assert %Ecto.Changeset{} = Mascotas.change_imagen_mascota(scope, imagen_mascota)
    end
  end

  describe "historiales_medicos" do
    alias Pets.Mascotas.HistorialMedico

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.MascotasFixtures

    @invalid_attrs %{fecha: nil, tipo: nil, mascota_id: nil}

    test "list_historiales_medicos/1 returns all scoped historiales_medicos" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      historial_medico = historial_medico_fixture(scope)
      other_historial_medico = historial_medico_fixture(other_scope)
      assert Mascotas.list_historiales_medicos(scope) == [historial_medico]
      assert Mascotas.list_historiales_medicos(other_scope) == [other_historial_medico]
    end

    test "get_historial_medico!/2 returns the historial_medico with given id" do
      scope = usuario_scope_fixture()
      historial_medico = historial_medico_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Mascotas.get_historial_medico!(scope, historial_medico.id) == historial_medico
      assert_raise Ecto.NoResultsError, fn -> Mascotas.get_historial_medico!(other_scope, historial_medico.id) end
    end

    test "create_historial_medico/2 with valid data creates a historial_medico" do
      valid_attrs = %{fecha: ~D[2025-10-30], tipo: "some tipo", mascota_id: 42}
      scope = usuario_scope_fixture()

      assert {:ok, %HistorialMedico{} = historial_medico} = Mascotas.create_historial_medico(scope, valid_attrs)
      assert historial_medico.fecha == ~D[2025-10-30]
      assert historial_medico.tipo == "some tipo"
      assert historial_medico.mascota_id == 42
      assert historial_medico.usuario_id == scope.usuario.id
    end

    test "create_historial_medico/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Mascotas.create_historial_medico(scope, @invalid_attrs)
    end

    test "update_historial_medico/3 with valid data updates the historial_medico" do
      scope = usuario_scope_fixture()
      historial_medico = historial_medico_fixture(scope)
      update_attrs = %{fecha: ~D[2025-10-31], tipo: "some updated tipo", mascota_id: 43}

      assert {:ok, %HistorialMedico{} = historial_medico} = Mascotas.update_historial_medico(scope, historial_medico, update_attrs)
      assert historial_medico.fecha == ~D[2025-10-31]
      assert historial_medico.tipo == "some updated tipo"
      assert historial_medico.mascota_id == 43
    end

    test "update_historial_medico/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      historial_medico = historial_medico_fixture(scope)

      assert_raise MatchError, fn ->
        Mascotas.update_historial_medico(other_scope, historial_medico, %{})
      end
    end

    test "update_historial_medico/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      historial_medico = historial_medico_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Mascotas.update_historial_medico(scope, historial_medico, @invalid_attrs)
      assert historial_medico == Mascotas.get_historial_medico!(scope, historial_medico.id)
    end

    test "delete_historial_medico/2 deletes the historial_medico" do
      scope = usuario_scope_fixture()
      historial_medico = historial_medico_fixture(scope)
      assert {:ok, %HistorialMedico{}} = Mascotas.delete_historial_medico(scope, historial_medico)
      assert_raise Ecto.NoResultsError, fn -> Mascotas.get_historial_medico!(scope, historial_medico.id) end
    end

    test "delete_historial_medico/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      historial_medico = historial_medico_fixture(scope)
      assert_raise MatchError, fn -> Mascotas.delete_historial_medico(other_scope, historial_medico) end
    end

    test "change_historial_medico/2 returns a historial_medico changeset" do
      scope = usuario_scope_fixture()
      historial_medico = historial_medico_fixture(scope)
      assert %Ecto.Changeset{} = Mascotas.change_historial_medico(scope, historial_medico)
    end
  end
end
