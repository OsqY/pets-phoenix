defmodule Pets.ChatsTest do
  use Pets.DataCase

  alias Pets.Chats

  describe "conversaciones" do
    alias Pets.Chats.Conversacion

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.ChatsFixtures

    @invalid_attrs %{emisor_id: nil, receptor_id: nil}

    test "list_conversaciones/1 returns all scoped conversaciones" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      conversacion = conversacion_fixture(scope)
      other_conversacion = conversacion_fixture(other_scope)
      assert Chats.list_conversaciones(scope) == [conversacion]
      assert Chats.list_conversaciones(other_scope) == [other_conversacion]
    end

    test "get_conversacion!/2 returns the conversacion with given id" do
      scope = usuario_scope_fixture()
      conversacion = conversacion_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Chats.get_conversacion!(scope, conversacion.id) == conversacion
      assert_raise Ecto.NoResultsError, fn -> Chats.get_conversacion!(other_scope, conversacion.id) end
    end

    test "create_conversacion/2 with valid data creates a conversacion" do
      valid_attrs = %{emisor_id: 42, receptor_id: 42}
      scope = usuario_scope_fixture()

      assert {:ok, %Conversacion{} = conversacion} = Chats.create_conversacion(scope, valid_attrs)
      assert conversacion.emisor_id == 42
      assert conversacion.receptor_id == 42
      assert conversacion.usuario_id == scope.usuario.id
    end

    test "create_conversacion/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.create_conversacion(scope, @invalid_attrs)
    end

    test "update_conversacion/3 with valid data updates the conversacion" do
      scope = usuario_scope_fixture()
      conversacion = conversacion_fixture(scope)
      update_attrs = %{emisor_id: 43, receptor_id: 43}

      assert {:ok, %Conversacion{} = conversacion} = Chats.update_conversacion(scope, conversacion, update_attrs)
      assert conversacion.emisor_id == 43
      assert conversacion.receptor_id == 43
    end

    test "update_conversacion/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      conversacion = conversacion_fixture(scope)

      assert_raise MatchError, fn ->
        Chats.update_conversacion(other_scope, conversacion, %{})
      end
    end

    test "update_conversacion/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      conversacion = conversacion_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Chats.update_conversacion(scope, conversacion, @invalid_attrs)
      assert conversacion == Chats.get_conversacion!(scope, conversacion.id)
    end

    test "delete_conversacion/2 deletes the conversacion" do
      scope = usuario_scope_fixture()
      conversacion = conversacion_fixture(scope)
      assert {:ok, %Conversacion{}} = Chats.delete_conversacion(scope, conversacion)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_conversacion!(scope, conversacion.id) end
    end

    test "delete_conversacion/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      conversacion = conversacion_fixture(scope)
      assert_raise MatchError, fn -> Chats.delete_conversacion(other_scope, conversacion) end
    end

    test "change_conversacion/2 returns a conversacion changeset" do
      scope = usuario_scope_fixture()
      conversacion = conversacion_fixture(scope)
      assert %Ecto.Changeset{} = Chats.change_conversacion(scope, conversacion)
    end
  end

  describe "mensajes" do
    alias Pets.Chats.Mensaje

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.ChatsFixtures

    @invalid_attrs %{contenido: nil, imagen: nil, fecha_hora: nil, emisor_id: nil, conversacion_id: nil, leido: nil}

    test "list_mensajes/1 returns all scoped mensajes" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      mensaje = mensaje_fixture(scope)
      other_mensaje = mensaje_fixture(other_scope)
      assert Chats.list_mensajes(scope) == [mensaje]
      assert Chats.list_mensajes(other_scope) == [other_mensaje]
    end

    test "get_mensaje!/2 returns the mensaje with given id" do
      scope = usuario_scope_fixture()
      mensaje = mensaje_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Chats.get_mensaje!(scope, mensaje.id) == mensaje
      assert_raise Ecto.NoResultsError, fn -> Chats.get_mensaje!(other_scope, mensaje.id) end
    end

    test "create_mensaje/2 with valid data creates a mensaje" do
      valid_attrs = %{contenido: "some contenido", imagen: "some imagen", fecha_hora: ~N[2025-11-03 22:08:00], emisor_id: 42, conversacion_id: 42, leido: true}
      scope = usuario_scope_fixture()

      assert {:ok, %Mensaje{} = mensaje} = Chats.create_mensaje(scope, valid_attrs)
      assert mensaje.contenido == "some contenido"
      assert mensaje.imagen == "some imagen"
      assert mensaje.fecha_hora == ~N[2025-11-03 22:08:00]
      assert mensaje.emisor_id == 42
      assert mensaje.conversacion_id == 42
      assert mensaje.leido == true
      assert mensaje.usuario_id == scope.usuario.id
    end

    test "create_mensaje/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.create_mensaje(scope, @invalid_attrs)
    end

    test "update_mensaje/3 with valid data updates the mensaje" do
      scope = usuario_scope_fixture()
      mensaje = mensaje_fixture(scope)
      update_attrs = %{contenido: "some updated contenido", imagen: "some updated imagen", fecha_hora: ~N[2025-11-04 22:08:00], emisor_id: 43, conversacion_id: 43, leido: false}

      assert {:ok, %Mensaje{} = mensaje} = Chats.update_mensaje(scope, mensaje, update_attrs)
      assert mensaje.contenido == "some updated contenido"
      assert mensaje.imagen == "some updated imagen"
      assert mensaje.fecha_hora == ~N[2025-11-04 22:08:00]
      assert mensaje.emisor_id == 43
      assert mensaje.conversacion_id == 43
      assert mensaje.leido == false
    end

    test "update_mensaje/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      mensaje = mensaje_fixture(scope)

      assert_raise MatchError, fn ->
        Chats.update_mensaje(other_scope, mensaje, %{})
      end
    end

    test "update_mensaje/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      mensaje = mensaje_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Chats.update_mensaje(scope, mensaje, @invalid_attrs)
      assert mensaje == Chats.get_mensaje!(scope, mensaje.id)
    end

    test "delete_mensaje/2 deletes the mensaje" do
      scope = usuario_scope_fixture()
      mensaje = mensaje_fixture(scope)
      assert {:ok, %Mensaje{}} = Chats.delete_mensaje(scope, mensaje)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_mensaje!(scope, mensaje.id) end
    end

    test "delete_mensaje/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      mensaje = mensaje_fixture(scope)
      assert_raise MatchError, fn -> Chats.delete_mensaje(other_scope, mensaje) end
    end

    test "change_mensaje/2 returns a mensaje changeset" do
      scope = usuario_scope_fixture()
      mensaje = mensaje_fixture(scope)
      assert %Ecto.Changeset{} = Chats.change_mensaje(scope, mensaje)
    end
  end

  describe "notificaciones" do
    alias Pets.Chats.Notificacion

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.ChatsFixtures

    @invalid_attrs %{contenido: nil, fehca: nil}

    test "list_notificaciones/1 returns all scoped notificaciones" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      notificacion = notificacion_fixture(scope)
      other_notificacion = notificacion_fixture(other_scope)
      assert Chats.list_notificaciones(scope) == [notificacion]
      assert Chats.list_notificaciones(other_scope) == [other_notificacion]
    end

    test "get_notificacion!/2 returns the notificacion with given id" do
      scope = usuario_scope_fixture()
      notificacion = notificacion_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Chats.get_notificacion!(scope, notificacion.id) == notificacion
      assert_raise Ecto.NoResultsError, fn -> Chats.get_notificacion!(other_scope, notificacion.id) end
    end

    test "create_notificacion/2 with valid data creates a notificacion" do
      valid_attrs = %{contenido: "some contenido", fehca: ~N[2025-11-03 22:09:00]}
      scope = usuario_scope_fixture()

      assert {:ok, %Notificacion{} = notificacion} = Chats.create_notificacion(scope, valid_attrs)
      assert notificacion.contenido == "some contenido"
      assert notificacion.fehca == ~N[2025-11-03 22:09:00]
      assert notificacion.usuario_id == scope.usuario.id
    end

    test "create_notificacion/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.create_notificacion(scope, @invalid_attrs)
    end

    test "update_notificacion/3 with valid data updates the notificacion" do
      scope = usuario_scope_fixture()
      notificacion = notificacion_fixture(scope)
      update_attrs = %{contenido: "some updated contenido", fehca: ~N[2025-11-04 22:09:00]}

      assert {:ok, %Notificacion{} = notificacion} = Chats.update_notificacion(scope, notificacion, update_attrs)
      assert notificacion.contenido == "some updated contenido"
      assert notificacion.fehca == ~N[2025-11-04 22:09:00]
    end

    test "update_notificacion/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      notificacion = notificacion_fixture(scope)

      assert_raise MatchError, fn ->
        Chats.update_notificacion(other_scope, notificacion, %{})
      end
    end

    test "update_notificacion/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      notificacion = notificacion_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Chats.update_notificacion(scope, notificacion, @invalid_attrs)
      assert notificacion == Chats.get_notificacion!(scope, notificacion.id)
    end

    test "delete_notificacion/2 deletes the notificacion" do
      scope = usuario_scope_fixture()
      notificacion = notificacion_fixture(scope)
      assert {:ok, %Notificacion{}} = Chats.delete_notificacion(scope, notificacion)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_notificacion!(scope, notificacion.id) end
    end

    test "delete_notificacion/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      notificacion = notificacion_fixture(scope)
      assert_raise MatchError, fn -> Chats.delete_notificacion(other_scope, notificacion) end
    end

    test "change_notificacion/2 returns a notificacion changeset" do
      scope = usuario_scope_fixture()
      notificacion = notificacion_fixture(scope)
      assert %Ecto.Changeset{} = Chats.change_notificacion(scope, notificacion)
    end
  end
end
