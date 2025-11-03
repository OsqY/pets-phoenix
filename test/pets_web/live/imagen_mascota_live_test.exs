defmodule PetsWeb.ImagenMascotaLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.MascotasFixtures

  @create_attrs %{url: "some url", mascota_id: 42}
  @update_attrs %{url: "some updated url", mascota_id: 43}
  @invalid_attrs %{url: nil, mascota_id: nil}

  setup :register_and_log_in_usuario

  defp create_imagen_mascota(%{scope: scope}) do
    imagen_mascota = imagen_mascota_fixture(scope)

    %{imagen_mascota: imagen_mascota}
  end

  describe "Index" do
    setup [:create_imagen_mascota]

    test "lists all imagenes_mascotas", %{conn: conn, imagen_mascota: imagen_mascota} do
      {:ok, _index_live, html} = live(conn, ~p"/imagenes_mascotas")

      assert html =~ "Listing Imagenes mascotas"
      assert html =~ imagen_mascota.url
    end

    test "saves new imagen_mascota", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/imagenes_mascotas")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Imagen mascota")
               |> render_click()
               |> follow_redirect(conn, ~p"/imagenes_mascotas/new")

      assert render(form_live) =~ "New Imagen mascota"

      assert form_live
             |> form("#imagen_mascota-form", imagen_mascota: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#imagen_mascota-form", imagen_mascota: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/imagenes_mascotas")

      html = render(index_live)
      assert html =~ "Imagen mascota created successfully"
      assert html =~ "some url"
    end

    test "updates imagen_mascota in listing", %{conn: conn, imagen_mascota: imagen_mascota} do
      {:ok, index_live, _html} = live(conn, ~p"/imagenes_mascotas")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#imagenes_mascotas-#{imagen_mascota.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/imagenes_mascotas/#{imagen_mascota}/edit")

      assert render(form_live) =~ "Edit Imagen mascota"

      assert form_live
             |> form("#imagen_mascota-form", imagen_mascota: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#imagen_mascota-form", imagen_mascota: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/imagenes_mascotas")

      html = render(index_live)
      assert html =~ "Imagen mascota updated successfully"
      assert html =~ "some updated url"
    end

    test "deletes imagen_mascota in listing", %{conn: conn, imagen_mascota: imagen_mascota} do
      {:ok, index_live, _html} = live(conn, ~p"/imagenes_mascotas")

      assert index_live |> element("#imagenes_mascotas-#{imagen_mascota.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#imagenes_mascotas-#{imagen_mascota.id}")
    end
  end

  describe "Show" do
    setup [:create_imagen_mascota]

    test "displays imagen_mascota", %{conn: conn, imagen_mascota: imagen_mascota} do
      {:ok, _show_live, html} = live(conn, ~p"/imagenes_mascotas/#{imagen_mascota}")

      assert html =~ "Show Imagen mascota"
      assert html =~ imagen_mascota.url
    end

    test "updates imagen_mascota and returns to show", %{conn: conn, imagen_mascota: imagen_mascota} do
      {:ok, show_live, _html} = live(conn, ~p"/imagenes_mascotas/#{imagen_mascota}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/imagenes_mascotas/#{imagen_mascota}/edit?return_to=show")

      assert render(form_live) =~ "Edit Imagen mascota"

      assert form_live
             |> form("#imagen_mascota-form", imagen_mascota: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#imagen_mascota-form", imagen_mascota: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/imagenes_mascotas/#{imagen_mascota}")

      html = render(show_live)
      assert html =~ "Imagen mascota updated successfully"
      assert html =~ "some updated url"
    end
  end
end
