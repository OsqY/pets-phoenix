defmodule PetsWeb.HistorialMedioLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.RefugioFixtures

  @create_attrs %{fecha: "2025-11-04", tipo: :vacuna, mascota_id: 42, refugio_id: 42}
  @update_attrs %{fecha: "2025-11-05", tipo: :tratamiento, mascota_id: 43, refugio_id: 43}
  @invalid_attrs %{fecha: nil, tipo: nil, mascota_id: nil, refugio_id: nil}

  setup :register_and_log_in_usuario

  defp create_historial_medio(%{scope: scope}) do
    historial_medio = historial_medio_fixture(scope)

    %{historial_medio: historial_medio}
  end

  describe "Index" do
    setup [:create_historial_medio]

    test "lists all historiales_medicos", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/historiales_medicos")

      assert html =~ "Listing Historiales medicos"
    end

    test "saves new historial_medio", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/historiales_medicos")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Historial medio")
               |> render_click()
               |> follow_redirect(conn, ~p"/historiales_medicos/new")

      assert render(form_live) =~ "New Historial medio"

      assert form_live
             |> form("#historial_medio-form", historial_medio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#historial_medio-form", historial_medio: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/historiales_medicos")

      html = render(index_live)
      assert html =~ "Historial medio created successfully"
    end

    test "updates historial_medio in listing", %{conn: conn, historial_medio: historial_medio} do
      {:ok, index_live, _html} = live(conn, ~p"/historiales_medicos")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#historiales_medicos-#{historial_medio.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/historiales_medicos/#{historial_medio}/edit")

      assert render(form_live) =~ "Edit Historial medio"

      assert form_live
             |> form("#historial_medio-form", historial_medio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#historial_medio-form", historial_medio: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/historiales_medicos")

      html = render(index_live)
      assert html =~ "Historial medio updated successfully"
    end

    test "deletes historial_medio in listing", %{conn: conn, historial_medio: historial_medio} do
      {:ok, index_live, _html} = live(conn, ~p"/historiales_medicos")

      assert index_live |> element("#historiales_medicos-#{historial_medio.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#historiales_medicos-#{historial_medio.id}")
    end
  end

  describe "Show" do
    setup [:create_historial_medio]

    test "displays historial_medio", %{conn: conn, historial_medio: historial_medio} do
      {:ok, _show_live, html} = live(conn, ~p"/historiales_medicos/#{historial_medio}")

      assert html =~ "Show Historial medio"
    end

    test "updates historial_medio and returns to show", %{conn: conn, historial_medio: historial_medio} do
      {:ok, show_live, _html} = live(conn, ~p"/historiales_medicos/#{historial_medio}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/historiales_medicos/#{historial_medio}/edit?return_to=show")

      assert render(form_live) =~ "Edit Historial medio"

      assert form_live
             |> form("#historial_medio-form", historial_medio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#historial_medio-form", historial_medio: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/historiales_medicos/#{historial_medio}")

      html = render(show_live)
      assert html =~ "Historial medio updated successfully"
    end
  end
end
