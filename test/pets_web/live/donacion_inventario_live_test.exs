defmodule PetsWeb.DonacionInventarioLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.RefugiosFixtures

  @create_attrs %{cantidad: 120.5, descripcion: "some descripcion", fecha: "2025-11-03", donantes: ["option1", "option2"], refugio_id: 42, medida: :unidades, tipo: :comida}
  @update_attrs %{cantidad: 456.7, descripcion: "some updated descripcion", fecha: "2025-11-04", donantes: ["option1"], refugio_id: 43, medida: :kg, tipo: :medicina}
  @invalid_attrs %{cantidad: nil, descripcion: nil, fecha: nil, donantes: [], refugio_id: nil, medida: nil, tipo: nil}

  setup :register_and_log_in_usuario

  defp create_donacion_inventario(%{scope: scope}) do
    donacion_inventario = donacion_inventario_fixture(scope)

    %{donacion_inventario: donacion_inventario}
  end

  describe "Index" do
    setup [:create_donacion_inventario]

    test "lists all donaciones_inventario", %{conn: conn, donacion_inventario: donacion_inventario} do
      {:ok, _index_live, html} = live(conn, ~p"/donaciones_inventario")

      assert html =~ "Listing Donaciones inventario"
      assert html =~ donacion_inventario.descripcion
    end

    test "saves new donacion_inventario", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/donaciones_inventario")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Donacion inventario")
               |> render_click()
               |> follow_redirect(conn, ~p"/donaciones_inventario/new")

      assert render(form_live) =~ "New Donacion inventario"

      assert form_live
             |> form("#donacion_inventario-form", donacion_inventario: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#donacion_inventario-form", donacion_inventario: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/donaciones_inventario")

      html = render(index_live)
      assert html =~ "Donacion inventario created successfully"
      assert html =~ "some descripcion"
    end

    test "updates donacion_inventario in listing", %{conn: conn, donacion_inventario: donacion_inventario} do
      {:ok, index_live, _html} = live(conn, ~p"/donaciones_inventario")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#donaciones_inventario-#{donacion_inventario.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/donaciones_inventario/#{donacion_inventario}/edit")

      assert render(form_live) =~ "Edit Donacion inventario"

      assert form_live
             |> form("#donacion_inventario-form", donacion_inventario: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#donacion_inventario-form", donacion_inventario: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/donaciones_inventario")

      html = render(index_live)
      assert html =~ "Donacion inventario updated successfully"
      assert html =~ "some updated descripcion"
    end

    test "deletes donacion_inventario in listing", %{conn: conn, donacion_inventario: donacion_inventario} do
      {:ok, index_live, _html} = live(conn, ~p"/donaciones_inventario")

      assert index_live |> element("#donaciones_inventario-#{donacion_inventario.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#donaciones_inventario-#{donacion_inventario.id}")
    end
  end

  describe "Show" do
    setup [:create_donacion_inventario]

    test "displays donacion_inventario", %{conn: conn, donacion_inventario: donacion_inventario} do
      {:ok, _show_live, html} = live(conn, ~p"/donaciones_inventario/#{donacion_inventario}")

      assert html =~ "Show Donacion inventario"
      assert html =~ donacion_inventario.descripcion
    end

    test "updates donacion_inventario and returns to show", %{conn: conn, donacion_inventario: donacion_inventario} do
      {:ok, show_live, _html} = live(conn, ~p"/donaciones_inventario/#{donacion_inventario}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/donaciones_inventario/#{donacion_inventario}/edit?return_to=show")

      assert render(form_live) =~ "Edit Donacion inventario"

      assert form_live
             |> form("#donacion_inventario-form", donacion_inventario: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#donacion_inventario-form", donacion_inventario: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/donaciones_inventario/#{donacion_inventario}")

      html = render(show_live)
      assert html =~ "Donacion inventario updated successfully"
      assert html =~ "some updated descripcion"
    end
  end
end
