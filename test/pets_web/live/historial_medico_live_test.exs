defmodule PetsWeb.HistorialMedicoLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.MascotasFixtures

  @create_attrs %{fecha: "2025-10-30", tipo: "some tipo", mascota_id: 42}
  @update_attrs %{fecha: "2025-10-31", tipo: "some updated tipo", mascota_id: 43}
  @invalid_attrs %{fecha: nil, tipo: nil, mascota_id: nil}

  setup :register_and_log_in_usuario

  defp create_historial_medico(%{scope: scope}) do
    historial_medico = historial_medico_fixture(scope)

    %{historial_medico: historial_medico}
  end

  describe "Index" do
    setup [:create_historial_medico]

    test "lists all historiales_medicos", %{conn: conn, historial_medico: historial_medico} do
      {:ok, _index_live, html} = live(conn, ~p"/historiales_medicos")

      assert html =~ "Listing Historiales medicos"
      assert html =~ historial_medico.tipo
    end

    test "saves new historial_medico", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/historiales_medicos")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Historial medico")
               |> render_click()
               |> follow_redirect(conn, ~p"/historiales_medicos/new")

      assert render(form_live) =~ "New Historial medico"

      assert form_live
             |> form("#historial_medico-form", historial_medico: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#historial_medico-form", historial_medico: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/historiales_medicos")

      html = render(index_live)
      assert html =~ "Historial medico created successfully"
      assert html =~ "some tipo"
    end

    test "updates historial_medico in listing", %{conn: conn, historial_medico: historial_medico} do
      {:ok, index_live, _html} = live(conn, ~p"/historiales_medicos")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#historiales_medicos-#{historial_medico.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/historiales_medicos/#{historial_medico}/edit")

      assert render(form_live) =~ "Edit Historial medico"

      assert form_live
             |> form("#historial_medico-form", historial_medico: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#historial_medico-form", historial_medico: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/historiales_medicos")

      html = render(index_live)
      assert html =~ "Historial medico updated successfully"
      assert html =~ "some updated tipo"
    end

    test "deletes historial_medico in listing", %{conn: conn, historial_medico: historial_medico} do
      {:ok, index_live, _html} = live(conn, ~p"/historiales_medicos")

      assert index_live |> element("#historiales_medicos-#{historial_medico.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#historiales_medicos-#{historial_medico.id}")
    end
  end

  describe "Show" do
    setup [:create_historial_medico]

    test "displays historial_medico", %{conn: conn, historial_medico: historial_medico} do
      {:ok, _show_live, html} = live(conn, ~p"/historiales_medicos/#{historial_medico}")

      assert html =~ "Show Historial medico"
      assert html =~ historial_medico.tipo
    end

    test "updates historial_medico and returns to show", %{conn: conn, historial_medico: historial_medico} do
      {:ok, show_live, _html} = live(conn, ~p"/historiales_medicos/#{historial_medico}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/historiales_medicos/#{historial_medico}/edit?return_to=show")

      assert render(form_live) =~ "Edit Historial medico"

      assert form_live
             |> form("#historial_medico-form", historial_medico: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#historial_medico-form", historial_medico: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/historiales_medicos/#{historial_medico}")

      html = render(show_live)
      assert html =~ "Historial medico updated successfully"
      assert html =~ "some updated tipo"
    end
  end
end
