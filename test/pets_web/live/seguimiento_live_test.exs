defmodule PetsWeb.SeguimientoLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.AdopcionesFixtures

  @create_attrs %{fecha: "2025-11-05", notas: "some notas", solicitud_id: 42, responsable_id: 42}
  @update_attrs %{fecha: "2025-11-06", notas: "some updated notas", solicitud_id: 43, responsable_id: 43}
  @invalid_attrs %{fecha: nil, notas: nil, solicitud_id: nil, responsable_id: nil}

  setup :register_and_log_in_usuario

  defp create_seguimiento(%{scope: scope}) do
    seguimiento = seguimiento_fixture(scope)

    %{seguimiento: seguimiento}
  end

  describe "Index" do
    setup [:create_seguimiento]

    test "lists all seguimientos", %{conn: conn, seguimiento: seguimiento} do
      {:ok, _index_live, html} = live(conn, ~p"/seguimientos")

      assert html =~ "Listing Seguimientos"
      assert html =~ seguimiento.notas
    end

    test "saves new seguimiento", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/seguimientos")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Seguimiento")
               |> render_click()
               |> follow_redirect(conn, ~p"/seguimientos/new")

      assert render(form_live) =~ "New Seguimiento"

      assert form_live
             |> form("#seguimiento-form", seguimiento: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#seguimiento-form", seguimiento: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/seguimientos")

      html = render(index_live)
      assert html =~ "Seguimiento created successfully"
      assert html =~ "some notas"
    end

    test "updates seguimiento in listing", %{conn: conn, seguimiento: seguimiento} do
      {:ok, index_live, _html} = live(conn, ~p"/seguimientos")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#seguimientos-#{seguimiento.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/seguimientos/#{seguimiento}/edit")

      assert render(form_live) =~ "Edit Seguimiento"

      assert form_live
             |> form("#seguimiento-form", seguimiento: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#seguimiento-form", seguimiento: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/seguimientos")

      html = render(index_live)
      assert html =~ "Seguimiento updated successfully"
      assert html =~ "some updated notas"
    end

    test "deletes seguimiento in listing", %{conn: conn, seguimiento: seguimiento} do
      {:ok, index_live, _html} = live(conn, ~p"/seguimientos")

      assert index_live |> element("#seguimientos-#{seguimiento.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#seguimientos-#{seguimiento.id}")
    end
  end

  describe "Show" do
    setup [:create_seguimiento]

    test "displays seguimiento", %{conn: conn, seguimiento: seguimiento} do
      {:ok, _show_live, html} = live(conn, ~p"/seguimientos/#{seguimiento}")

      assert html =~ "Show Seguimiento"
      assert html =~ seguimiento.notas
    end

    test "updates seguimiento and returns to show", %{conn: conn, seguimiento: seguimiento} do
      {:ok, show_live, _html} = live(conn, ~p"/seguimientos/#{seguimiento}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/seguimientos/#{seguimiento}/edit?return_to=show")

      assert render(form_live) =~ "Edit Seguimiento"

      assert form_live
             |> form("#seguimiento-form", seguimiento: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#seguimiento-form", seguimiento: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/seguimientos/#{seguimiento}")

      html = render(show_live)
      assert html =~ "Seguimiento updated successfully"
      assert html =~ "some updated notas"
    end
  end
end
