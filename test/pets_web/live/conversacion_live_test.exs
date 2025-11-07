defmodule PetsWeb.ConversacionLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.ChatsFixtures

  @create_attrs %{emisor_id: 42, receptor_id: 42}
  @update_attrs %{emisor_id: 43, receptor_id: 43}
  @invalid_attrs %{emisor_id: nil, receptor_id: nil}

  setup :register_and_log_in_usuario

  defp create_conversacion(%{scope: scope}) do
    conversacion = conversacion_fixture(scope)

    %{conversacion: conversacion}
  end

  describe "Index" do
    setup [:create_conversacion]

    test "lists all conversaciones", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/conversaciones")

      assert html =~ "Listing Conversaciones"
    end

    test "saves new conversacion", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/conversaciones")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Conversacion")
               |> render_click()
               |> follow_redirect(conn, ~p"/conversaciones/new")

      assert render(form_live) =~ "New Conversacion"

      assert form_live
             |> form("#conversacion-form", conversacion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#conversacion-form", conversacion: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/conversaciones")

      html = render(index_live)
      assert html =~ "Conversacion created successfully"
    end

    test "updates conversacion in listing", %{conn: conn, conversacion: conversacion} do
      {:ok, index_live, _html} = live(conn, ~p"/conversaciones")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#conversaciones-#{conversacion.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/conversaciones/#{conversacion}/edit")

      assert render(form_live) =~ "Edit Conversacion"

      assert form_live
             |> form("#conversacion-form", conversacion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#conversacion-form", conversacion: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/conversaciones")

      html = render(index_live)
      assert html =~ "Conversacion updated successfully"
    end

    test "deletes conversacion in listing", %{conn: conn, conversacion: conversacion} do
      {:ok, index_live, _html} = live(conn, ~p"/conversaciones")

      assert index_live |> element("#conversaciones-#{conversacion.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#conversaciones-#{conversacion.id}")
    end
  end

  describe "Show" do
    setup [:create_conversacion]

    test "displays conversacion", %{conn: conn, conversacion: conversacion} do
      {:ok, _show_live, html} = live(conn, ~p"/conversaciones/#{conversacion}")

      assert html =~ "Show Conversacion"
    end

    test "updates conversacion and returns to show", %{conn: conn, conversacion: conversacion} do
      {:ok, show_live, _html} = live(conn, ~p"/conversaciones/#{conversacion}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/conversaciones/#{conversacion}/edit?return_to=show")

      assert render(form_live) =~ "Edit Conversacion"

      assert form_live
             |> form("#conversacion-form", conversacion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#conversacion-form", conversacion: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/conversaciones/#{conversacion}")

      html = render(show_live)
      assert html =~ "Conversacion updated successfully"
    end
  end
end
