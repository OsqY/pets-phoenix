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
end
