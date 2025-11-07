defmodule PetsWeb.DonacionDineroLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.RefugiosFixtures

  @create_attrs %{monto: 120.5, descripcion: "some descripcion", fecha: "2025-11-03", donantes: ["option1", "option2"], refugio_id: 42}
  @update_attrs %{monto: 456.7, descripcion: "some updated descripcion", fecha: "2025-11-04", donantes: ["option1"], refugio_id: 43}
  @invalid_attrs %{monto: nil, descripcion: nil, fecha: nil, donantes: [], refugio_id: nil}

  setup :register_and_log_in_usuario

  defp create_donacion_dinero(%{scope: scope}) do
    donacion_dinero = donacion_dinero_fixture(scope)

    %{donacion_dinero: donacion_dinero}
  end

  describe "Index" do
    setup [:create_donacion_dinero]

    test "lists all donaciones_dinero", %{conn: conn, donacion_dinero: donacion_dinero} do
      {:ok, _index_live, html} = live(conn, ~p"/donaciones_dinero")

      assert html =~ "Listing Donaciones dinero"
      assert html =~ donacion_dinero.descripcion
    end

    test "saves new donacion_dinero", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/donaciones_dinero")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Donacion dinero")
               |> render_click()
               |> follow_redirect(conn, ~p"/donaciones_dinero/new")

      assert render(form_live) =~ "New Donacion dinero"

      assert form_live
             |> form("#donacion_dinero-form", donacion_dinero: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#donacion_dinero-form", donacion_dinero: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/donaciones_dinero")

      html = render(index_live)
      assert html =~ "Donacion dinero created successfully"
      assert html =~ "some descripcion"
    end

    test "updates donacion_dinero in listing", %{conn: conn, donacion_dinero: donacion_dinero} do
      {:ok, index_live, _html} = live(conn, ~p"/donaciones_dinero")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#donaciones_dinero-#{donacion_dinero.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/donaciones_dinero/#{donacion_dinero}/edit")

      assert render(form_live) =~ "Edit Donacion dinero"

      assert form_live
             |> form("#donacion_dinero-form", donacion_dinero: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#donacion_dinero-form", donacion_dinero: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/donaciones_dinero")

      html = render(index_live)
      assert html =~ "Donacion dinero updated successfully"
      assert html =~ "some updated descripcion"
    end

    test "deletes donacion_dinero in listing", %{conn: conn, donacion_dinero: donacion_dinero} do
      {:ok, index_live, _html} = live(conn, ~p"/donaciones_dinero")

      assert index_live |> element("#donaciones_dinero-#{donacion_dinero.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#donaciones_dinero-#{donacion_dinero.id}")
    end
  end

  describe "Show" do
    setup [:create_donacion_dinero]

    test "displays donacion_dinero", %{conn: conn, donacion_dinero: donacion_dinero} do
      {:ok, _show_live, html} = live(conn, ~p"/donaciones_dinero/#{donacion_dinero}")

      assert html =~ "Show Donacion dinero"
      assert html =~ donacion_dinero.descripcion
    end

    test "updates donacion_dinero and returns to show", %{conn: conn, donacion_dinero: donacion_dinero} do
      {:ok, show_live, _html} = live(conn, ~p"/donaciones_dinero/#{donacion_dinero}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/donaciones_dinero/#{donacion_dinero}/edit?return_to=show")

      assert render(form_live) =~ "Edit Donacion dinero"

      assert form_live
             |> form("#donacion_dinero-form", donacion_dinero: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#donacion_dinero-form", donacion_dinero: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/donaciones_dinero/#{donacion_dinero}")

      html = render(show_live)
      assert html =~ "Donacion dinero updated successfully"
      assert html =~ "some updated descripcion"
    end
  end
end
