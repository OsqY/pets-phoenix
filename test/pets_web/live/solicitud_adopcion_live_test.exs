defmodule PetsWeb.SolicitudAdopcionLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.AdopcionesFixtures

  @create_attrs %{estado: :pendiente, fecha_solicitud: "2025-11-05", fecha_revision: "2025-11-05", adoptante_id: 42, mascota_id: 42}
  @update_attrs %{estado: :revisado, fecha_solicitud: "2025-11-06", fecha_revision: "2025-11-06", adoptante_id: 43, mascota_id: 43}
  @invalid_attrs %{estado: nil, fecha_solicitud: nil, fecha_revision: nil, adoptante_id: nil, mascota_id: nil}

  setup :register_and_log_in_usuario

  defp create_solicitud_adopcion(%{scope: scope}) do
    solicitud_adopcion = solicitud_adopcion_fixture(scope)

    %{solicitud_adopcion: solicitud_adopcion}
  end

  describe "Index" do
    setup [:create_solicitud_adopcion]

    test "lists all solicitudes_adopcion", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/solicitudes_adopcion")

      assert html =~ "Listing Solicitudes adopcion"
    end

    test "saves new solicitud_adopcion", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/solicitudes_adopcion")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Solicitud adopcion")
               |> render_click()
               |> follow_redirect(conn, ~p"/solicitudes_adopcion/new")

      assert render(form_live) =~ "New Solicitud adopcion"

      assert form_live
             |> form("#solicitud_adopcion-form", solicitud_adopcion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#solicitud_adopcion-form", solicitud_adopcion: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/solicitudes_adopcion")

      html = render(index_live)
      assert html =~ "Solicitud adopcion created successfully"
    end

    test "updates solicitud_adopcion in listing", %{conn: conn, solicitud_adopcion: solicitud_adopcion} do
      {:ok, index_live, _html} = live(conn, ~p"/solicitudes_adopcion")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#solicitudes_adopcion-#{solicitud_adopcion.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/solicitudes_adopcion/#{solicitud_adopcion}/edit")

      assert render(form_live) =~ "Edit Solicitud adopcion"

      assert form_live
             |> form("#solicitud_adopcion-form", solicitud_adopcion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#solicitud_adopcion-form", solicitud_adopcion: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/solicitudes_adopcion")

      html = render(index_live)
      assert html =~ "Solicitud adopcion updated successfully"
    end

    test "deletes solicitud_adopcion in listing", %{conn: conn, solicitud_adopcion: solicitud_adopcion} do
      {:ok, index_live, _html} = live(conn, ~p"/solicitudes_adopcion")

      assert index_live |> element("#solicitudes_adopcion-#{solicitud_adopcion.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#solicitudes_adopcion-#{solicitud_adopcion.id}")
    end
  end

  describe "Show" do
    setup [:create_solicitud_adopcion]

    test "displays solicitud_adopcion", %{conn: conn, solicitud_adopcion: solicitud_adopcion} do
      {:ok, _show_live, html} = live(conn, ~p"/solicitudes_adopcion/#{solicitud_adopcion}")

      assert html =~ "Show Solicitud adopcion"
    end

    test "updates solicitud_adopcion and returns to show", %{conn: conn, solicitud_adopcion: solicitud_adopcion} do
      {:ok, show_live, _html} = live(conn, ~p"/solicitudes_adopcion/#{solicitud_adopcion}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/solicitudes_adopcion/#{solicitud_adopcion}/edit?return_to=show")

      assert render(form_live) =~ "Edit Solicitud adopcion"

      assert form_live
             |> form("#solicitud_adopcion-form", solicitud_adopcion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#solicitud_adopcion-form", solicitud_adopcion: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/solicitudes_adopcion/#{solicitud_adopcion}")

      html = render(show_live)
      assert html =~ "Solicitud adopcion updated successfully"
    end
  end
end
