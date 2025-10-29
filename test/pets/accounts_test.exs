defmodule Pets.AccountsTest do
  use Pets.DataCase

  alias Pets.Accounts

  describe "users" do
    alias Pets.Accounts.User

    import Pets.AccountsFixtures

    @invalid_attrs %{nombres: nil, apellidos: nil, correo: nil, nombre_usuario: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{nombres: "some nombres", apellidos: "some apellidos", correo: "some correo", nombre_usuario: "some nombre_usuario"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.nombres == "some nombres"
      assert user.apellidos == "some apellidos"
      assert user.correo == "some correo"
      assert user.nombre_usuario == "some nombre_usuario"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{nombres: "some updated nombres", apellidos: "some updated apellidos", correo: "some updated correo", nombre_usuario: "some updated nombre_usuario"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.nombres == "some updated nombres"
      assert user.apellidos == "some updated apellidos"
      assert user.correo == "some updated correo"
      assert user.nombre_usuario == "some updated nombre_usuario"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
