defmodule PetsWeb.MensajeLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.ChatsFixtures

  @create_attrs %{contenido: "some contenido", imagen: "some imagen", fecha_hora: "2025-11-03T22:08:00", emisor_id: 42, conversacion_id: 42, leido: true}
  @update_attrs %{contenido: "some updated contenido", imagen: "some updated imagen", fecha_hora: "2025-11-04T22:08:00", emisor_id: 43, conversacion_id: 43, leido: false}
  @invalid_attrs %{contenido: nil, imagen: nil, fecha_hora: nil, emisor_id: nil, conversacion_id: nil, leido: false}

  setup :register_and_log_in_usuario

  defp create_mensaje(%{scope: scope}) do
    mensaje = mensaje_fixture(scope)

    %{mensaje: mensaje}
  end

  describe "Index" do
    setup [:create_mensaje]

    test "lists all mensajes", %{conn: conn, mensaje: mensaje} do
      {:ok, _index_live, html} = live(conn, ~p"/mensajes")

      assert html =~ "Listing Mensajes"
      assert html =~ mensaje.contenido
    end

    test "saves new mensaje", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/mensajes")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Mensaje")
               |> render_click()
               |> follow_redirect(conn, ~p"/mensajes/new")

      assert render(form_live) =~ "New Mensaje"

      assert form_live
             |> form("#mensaje-form", mensaje: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#mensaje-form", mensaje: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/mensajes")

      html = render(index_live)
      assert html =~ "Mensaje created successfully"
      assert html =~ "some contenido"
    end

    test "updates mensaje in listing", %{conn: conn, mensaje: mensaje} do
      {:ok, index_live, _html} = live(conn, ~p"/mensajes")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#mensajes-#{mensaje.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/mensajes/#{mensaje}/edit")

      assert render(form_live) =~ "Edit Mensaje"

      assert form_live
             |> form("#mensaje-form", mensaje: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#mensaje-form", mensaje: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/mensajes")

      html = render(index_live)
      assert html =~ "Mensaje updated successfully"
      assert html =~ "some updated contenido"
    end

    test "deletes mensaje in listing", %{conn: conn, mensaje: mensaje} do
      {:ok, index_live, _html} = live(conn, ~p"/mensajes")

      assert index_live |> element("#mensajes-#{mensaje.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#mensajes-#{mensaje.id}")
    end
  end

  describe "Show" do
    setup [:create_mensaje]

    test "displays mensaje", %{conn: conn, mensaje: mensaje} do
      {:ok, _show_live, html} = live(conn, ~p"/mensajes/#{mensaje}")

      assert html =~ "Show Mensaje"
      assert html =~ mensaje.contenido
    end

    test "updates mensaje and returns to show", %{conn: conn, mensaje: mensaje} do
      {:ok, show_live, _html} = live(conn, ~p"/mensajes/#{mensaje}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/mensajes/#{mensaje}/edit?return_to=show")

      assert render(form_live) =~ "Edit Mensaje"

      assert form_live
             |> form("#mensaje-form", mensaje: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#mensaje-form", mensaje: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/mensajes/#{mensaje}")

      html = render(show_live)
      assert html =~ "Mensaje updated successfully"
      assert html =~ "some updated contenido"
    end
  end
end
