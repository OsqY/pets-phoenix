defmodule PetsWeb.EspecieLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.MascotasFixtures

  @create_attrs %{nombre: "some nombre"}
  @update_attrs %{nombre: "some updated nombre"}
  @invalid_attrs %{nombre: nil}

  setup :register_and_log_in_usuario

  defp create_especie(%{scope: scope}) do
    especie = especie_fixture(scope)

    %{especie: especie}
  end

  describe "Index" do
    setup [:create_especie]

    test "lists all especies", %{conn: conn, especie: especie} do
      {:ok, _index_live, html} = live(conn, ~p"/especies")

      assert html =~ "Listing Especies"
      assert html =~ especie.nombre
    end

    test "saves new especie", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/especies")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Especie")
               |> render_click()
               |> follow_redirect(conn, ~p"/especies/new")

      assert render(form_live) =~ "New Especie"

      assert form_live
             |> form("#especie-form", especie: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#especie-form", especie: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/especies")

      html = render(index_live)
      assert html =~ "Especie created successfully"
      assert html =~ "some nombre"
    end

    test "updates especie in listing", %{conn: conn, especie: especie} do
      {:ok, index_live, _html} = live(conn, ~p"/especies")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#especies-#{especie.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/especies/#{especie}/edit")

      assert render(form_live) =~ "Edit Especie"

      assert form_live
             |> form("#especie-form", especie: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#especie-form", especie: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/especies")

      html = render(index_live)
      assert html =~ "Especie updated successfully"
      assert html =~ "some updated nombre"
    end

    test "deletes especie in listing", %{conn: conn, especie: especie} do
      {:ok, index_live, _html} = live(conn, ~p"/especies")

      assert index_live |> element("#especies-#{especie.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#especies-#{especie.id}")
    end
  end

  describe "Show" do
    setup [:create_especie]

    test "displays especie", %{conn: conn, especie: especie} do
      {:ok, _show_live, html} = live(conn, ~p"/especies/#{especie}")

      assert html =~ "Show Especie"
      assert html =~ especie.nombre
    end

    test "updates especie and returns to show", %{conn: conn, especie: especie} do
      {:ok, show_live, _html} = live(conn, ~p"/especies/#{especie}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/especies/#{especie}/edit?return_to=show")

      assert render(form_live) =~ "Edit Especie"

      assert form_live
             |> form("#especie-form", especie: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#especie-form", especie: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/especies/#{especie}")

      html = render(show_live)
      assert html =~ "Especie updated successfully"
      assert html =~ "some updated nombre"
    end
  end
end
