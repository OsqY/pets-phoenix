defmodule PetsWeb.NotificacionLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.ChatsFixtures

  @create_attrs %{contenido: "some contenido", fehca: "2025-11-03T22:09:00"}
  @update_attrs %{contenido: "some updated contenido", fehca: "2025-11-04T22:09:00"}
  @invalid_attrs %{contenido: nil, fehca: nil}

  setup :register_and_log_in_usuario

  defp create_notificacion(%{scope: scope}) do
    notificacion = notificacion_fixture(scope)

    %{notificacion: notificacion}
  end

  describe "Index" do
    setup [:create_notificacion]

    test "lists all notificaciones", %{conn: conn, notificacion: notificacion} do
      {:ok, _index_live, html} = live(conn, ~p"/notificaciones")

      assert html =~ "Listing Notificaciones"
      assert html =~ notificacion.contenido
    end

    test "saves new notificacion", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/notificaciones")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Notificacion")
               |> render_click()
               |> follow_redirect(conn, ~p"/notificaciones/new")

      assert render(form_live) =~ "New Notificacion"

      assert form_live
             |> form("#notificacion-form", notificacion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#notificacion-form", notificacion: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/notificaciones")

      html = render(index_live)
      assert html =~ "Notificacion created successfully"
      assert html =~ "some contenido"
    end

    test "updates notificacion in listing", %{conn: conn, notificacion: notificacion} do
      {:ok, index_live, _html} = live(conn, ~p"/notificaciones")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#notificaciones-#{notificacion.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/notificaciones/#{notificacion}/edit")

      assert render(form_live) =~ "Edit Notificacion"

      assert form_live
             |> form("#notificacion-form", notificacion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#notificacion-form", notificacion: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/notificaciones")

      html = render(index_live)
      assert html =~ "Notificacion updated successfully"
      assert html =~ "some updated contenido"
    end

    test "deletes notificacion in listing", %{conn: conn, notificacion: notificacion} do
      {:ok, index_live, _html} = live(conn, ~p"/notificaciones")

      assert index_live |> element("#notificaciones-#{notificacion.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#notificaciones-#{notificacion.id}")
    end
  end

  describe "Show" do
    setup [:create_notificacion]

    test "displays notificacion", %{conn: conn, notificacion: notificacion} do
      {:ok, _show_live, html} = live(conn, ~p"/notificaciones/#{notificacion}")

      assert html =~ "Show Notificacion"
      assert html =~ notificacion.contenido
    end

    test "updates notificacion and returns to show", %{conn: conn, notificacion: notificacion} do
      {:ok, show_live, _html} = live(conn, ~p"/notificaciones/#{notificacion}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/notificaciones/#{notificacion}/edit?return_to=show")

      assert render(form_live) =~ "Edit Notificacion"

      assert form_live
             |> form("#notificacion-form", notificacion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#notificacion-form", notificacion: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/notificaciones/#{notificacion}")

      html = render(show_live)
      assert html =~ "Notificacion updated successfully"
      assert html =~ "some updated contenido"
    end
  end
end
