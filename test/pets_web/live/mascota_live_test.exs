defmodule PetsWeb.MascotaLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.MascotasFixtures

  @create_attrs %{usuario_id: 42, nombre: "some nombre", descripcion: "some descripcion", edad: 42, sexo: "some sexo", tamanio: "some tamanio", peso: 120.5, color_id: 42, especie_id: 42, raza_id: 42}
  @update_attrs %{usuario_id: 43, nombre: "some updated nombre", descripcion: "some updated descripcion", edad: 43, sexo: "some updated sexo", tamanio: "some updated tamanio", peso: 456.7, color_id: 43, especie_id: 43, raza_id: 43}
  @invalid_attrs %{usuario_id: nil, nombre: nil, descripcion: nil, edad: nil, sexo: nil, tamanio: nil, peso: nil, color_id: nil, especie_id: nil, raza_id: nil}

  setup :register_and_log_in_usuario

  defp create_mascota(%{scope: scope}) do
    mascota = mascota_fixture(scope)

    %{mascota: mascota}
  end

  describe "Index" do
    setup [:create_mascota]

    test "lists all mascotas", %{conn: conn, mascota: mascota} do
      {:ok, _index_live, html} = live(conn, ~p"/mascotas")

      assert html =~ "Listing Mascotas"
      assert html =~ mascota.nombre
    end

    test "saves new mascota", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/mascotas")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Mascota")
               |> render_click()
               |> follow_redirect(conn, ~p"/mascotas/new")

      assert render(form_live) =~ "New Mascota"

      assert form_live
             |> form("#mascota-form", mascota: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#mascota-form", mascota: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/mascotas")

      html = render(index_live)
      assert html =~ "Mascota created successfully"
      assert html =~ "some nombre"
    end

    test "updates mascota in listing", %{conn: conn, mascota: mascota} do
      {:ok, index_live, _html} = live(conn, ~p"/mascotas")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#mascotas-#{mascota.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/mascotas/#{mascota}/edit")

      assert render(form_live) =~ "Edit Mascota"

      assert form_live
             |> form("#mascota-form", mascota: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#mascota-form", mascota: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/mascotas")

      html = render(index_live)
      assert html =~ "Mascota updated successfully"
      assert html =~ "some updated nombre"
    end

    test "deletes mascota in listing", %{conn: conn, mascota: mascota} do
      {:ok, index_live, _html} = live(conn, ~p"/mascotas")

      assert index_live |> element("#mascotas-#{mascota.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#mascotas-#{mascota.id}")
    end
  end

  describe "Show" do
    setup [:create_mascota]

    test "displays mascota", %{conn: conn, mascota: mascota} do
      {:ok, _show_live, html} = live(conn, ~p"/mascotas/#{mascota}")

      assert html =~ "Show Mascota"
      assert html =~ mascota.nombre
    end

    test "updates mascota and returns to show", %{conn: conn, mascota: mascota} do
      {:ok, show_live, _html} = live(conn, ~p"/mascotas/#{mascota}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/mascotas/#{mascota}/edit?return_to=show")

      assert render(form_live) =~ "Edit Mascota"

      assert form_live
             |> form("#mascota-form", mascota: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#mascota-form", mascota: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/mascotas/#{mascota}")

      html = render(show_live)
      assert html =~ "Mascota updated successfully"
      assert html =~ "some updated nombre"
    end
  end
end
