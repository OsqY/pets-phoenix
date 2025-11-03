defmodule PetsWeb.ColorLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.MascotasFixtures

  @create_attrs %{nombre: "some nombre", especie_id: 42}
  @update_attrs %{nombre: "some updated nombre", especie_id: 43}
  @invalid_attrs %{nombre: nil, especie_id: nil}

  setup :register_and_log_in_usuario

  defp create_color(%{scope: scope}) do
    color = color_fixture(scope)

    %{color: color}
  end

  describe "Index" do
    setup [:create_color]

    test "lists all colores", %{conn: conn, color: color} do
      {:ok, _index_live, html} = live(conn, ~p"/colores")

      assert html =~ "Listing Colores"
      assert html =~ color.nombre
    end

    test "saves new color", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/colores")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Color")
               |> render_click()
               |> follow_redirect(conn, ~p"/colores/new")

      assert render(form_live) =~ "New Color"

      assert form_live
             |> form("#color-form", color: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#color-form", color: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/colores")

      html = render(index_live)
      assert html =~ "Color created successfully"
      assert html =~ "some nombre"
    end

    test "updates color in listing", %{conn: conn, color: color} do
      {:ok, index_live, _html} = live(conn, ~p"/colores")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#colores-#{color.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/colores/#{color}/edit")

      assert render(form_live) =~ "Edit Color"

      assert form_live
             |> form("#color-form", color: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#color-form", color: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/colores")

      html = render(index_live)
      assert html =~ "Color updated successfully"
      assert html =~ "some updated nombre"
    end

    test "deletes color in listing", %{conn: conn, color: color} do
      {:ok, index_live, _html} = live(conn, ~p"/colores")

      assert index_live |> element("#colores-#{color.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#colores-#{color.id}")
    end
  end

  describe "Show" do
    setup [:create_color]

    test "displays color", %{conn: conn, color: color} do
      {:ok, _show_live, html} = live(conn, ~p"/colores/#{color}")

      assert html =~ "Show Color"
      assert html =~ color.nombre
    end

    test "updates color and returns to show", %{conn: conn, color: color} do
      {:ok, show_live, _html} = live(conn, ~p"/colores/#{color}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/colores/#{color}/edit?return_to=show")

      assert render(form_live) =~ "Edit Color"

      assert form_live
             |> form("#color-form", color: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#color-form", color: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/colores/#{color}")

      html = render(show_live)
      assert html =~ "Color updated successfully"
      assert html =~ "some updated nombre"
    end
  end
end
