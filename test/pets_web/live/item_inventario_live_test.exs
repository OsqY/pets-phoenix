defmodule PetsWeb.ItemInventarioLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.RefugiosFixtures

  @create_attrs %{nombre: "some nombre", descripcion: "some descripcion", cantidad: 120.5, refugio_id: 42, medida: :unidades, tipo: :comida}
  @update_attrs %{nombre: "some updated nombre", descripcion: "some updated descripcion", cantidad: 456.7, refugio_id: 43, medida: :kg, tipo: :medicina}
  @invalid_attrs %{nombre: nil, descripcion: nil, cantidad: nil, refugio_id: nil, medida: nil, tipo: nil}

  setup :register_and_log_in_usuario

  defp create_item_inventario(%{scope: scope}) do
    item_inventario = item_inventario_fixture(scope)

    %{item_inventario: item_inventario}
  end

  describe "Index" do
    setup [:create_item_inventario]

    test "lists all items_inventario", %{conn: conn, item_inventario: item_inventario} do
      {:ok, _index_live, html} = live(conn, ~p"/items_inventario")

      assert html =~ "Listing Items inventario"
      assert html =~ item_inventario.nombre
    end

    test "saves new item_inventario", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/items_inventario")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Item inventario")
               |> render_click()
               |> follow_redirect(conn, ~p"/items_inventario/new")

      assert render(form_live) =~ "New Item inventario"

      assert form_live
             |> form("#item_inventario-form", item_inventario: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#item_inventario-form", item_inventario: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/items_inventario")

      html = render(index_live)
      assert html =~ "Item inventario created successfully"
      assert html =~ "some nombre"
    end

    test "updates item_inventario in listing", %{conn: conn, item_inventario: item_inventario} do
      {:ok, index_live, _html} = live(conn, ~p"/items_inventario")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#items_inventario-#{item_inventario.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/items_inventario/#{item_inventario}/edit")

      assert render(form_live) =~ "Edit Item inventario"

      assert form_live
             |> form("#item_inventario-form", item_inventario: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#item_inventario-form", item_inventario: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/items_inventario")

      html = render(index_live)
      assert html =~ "Item inventario updated successfully"
      assert html =~ "some updated nombre"
    end

    test "deletes item_inventario in listing", %{conn: conn, item_inventario: item_inventario} do
      {:ok, index_live, _html} = live(conn, ~p"/items_inventario")

      assert index_live |> element("#items_inventario-#{item_inventario.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#items_inventario-#{item_inventario.id}")
    end
  end

  describe "Show" do
    setup [:create_item_inventario]

    test "displays item_inventario", %{conn: conn, item_inventario: item_inventario} do
      {:ok, _show_live, html} = live(conn, ~p"/items_inventario/#{item_inventario}")

      assert html =~ "Show Item inventario"
      assert html =~ item_inventario.nombre
    end

    test "updates item_inventario and returns to show", %{conn: conn, item_inventario: item_inventario} do
      {:ok, show_live, _html} = live(conn, ~p"/items_inventario/#{item_inventario}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/items_inventario/#{item_inventario}/edit?return_to=show")

      assert render(form_live) =~ "Edit Item inventario"

      assert form_live
             |> form("#item_inventario-form", item_inventario: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#item_inventario-form", item_inventario: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/items_inventario/#{item_inventario}")

      html = render(show_live)
      assert html =~ "Item inventario updated successfully"
      assert html =~ "some updated nombre"
    end
  end
end
