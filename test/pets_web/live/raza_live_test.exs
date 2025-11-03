defmodule PetsWeb.RazaLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.MascotasFixtures

  @create_attrs %{nombre: "some nombre"}
  @update_attrs %{nombre: "some updated nombre"}
  @invalid_attrs %{nombre: nil}

  setup :register_and_log_in_usuario

  defp create_raza(%{scope: scope}) do
    raza = raza_fixture(scope)

    %{raza: raza}
  end

  describe "Index" do
    setup [:create_raza]

    test "lists all razas", %{conn: conn, raza: raza} do
      {:ok, _index_live, html} = live(conn, ~p"/razas")

      assert html =~ "Listing Razas"
      assert html =~ raza.nombre
    end

    test "saves new raza", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/razas")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Raza")
               |> render_click()
               |> follow_redirect(conn, ~p"/razas/new")

      assert render(form_live) =~ "New Raza"

      assert form_live
             |> form("#raza-form", raza: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#raza-form", raza: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/razas")

      html = render(index_live)
      assert html =~ "Raza created successfully"
      assert html =~ "some nombre"
    end

    test "updates raza in listing", %{conn: conn, raza: raza} do
      {:ok, index_live, _html} = live(conn, ~p"/razas")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#razas-#{raza.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/razas/#{raza}/edit")

      assert render(form_live) =~ "Edit Raza"

      assert form_live
             |> form("#raza-form", raza: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#raza-form", raza: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/razas")

      html = render(index_live)
      assert html =~ "Raza updated successfully"
      assert html =~ "some updated nombre"
    end

    test "deletes raza in listing", %{conn: conn, raza: raza} do
      {:ok, index_live, _html} = live(conn, ~p"/razas")

      assert index_live |> element("#razas-#{raza.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#razas-#{raza.id}")
    end
  end

  describe "Show" do
    setup [:create_raza]

    test "displays raza", %{conn: conn, raza: raza} do
      {:ok, _show_live, html} = live(conn, ~p"/razas/#{raza}")

      assert html =~ "Show Raza"
      assert html =~ raza.nombre
    end

    test "updates raza and returns to show", %{conn: conn, raza: raza} do
      {:ok, show_live, _html} = live(conn, ~p"/razas/#{raza}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/razas/#{raza}/edit?return_to=show")

      assert render(form_live) =~ "Edit Raza"

      assert form_live
             |> form("#raza-form", raza: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#raza-form", raza: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/razas/#{raza}")

      html = render(show_live)
      assert html =~ "Raza updated successfully"
      assert html =~ "some updated nombre"
    end
  end
end
