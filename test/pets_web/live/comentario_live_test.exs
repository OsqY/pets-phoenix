defmodule PetsWeb.ComentarioLiveTest do
  use PetsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pets.PostsFixtures

  @create_attrs %{usuario_id: 42, contenido: "some contenido", likes: 42}
  @update_attrs %{usuario_id: 43, contenido: "some updated contenido", likes: 43}
  @invalid_attrs %{usuario_id: nil, contenido: nil, likes: nil}

  setup :register_and_log_in_usuario

  defp create_comentario(%{scope: scope}) do
    comentario = comentario_fixture(scope)

    %{comentario: comentario}
  end

  describe "Index" do
    setup [:create_comentario]

    test "lists all comentarios", %{conn: conn, comentario: comentario} do
      {:ok, _index_live, html} = live(conn, ~p"/comentarios")

      assert html =~ "Listing Comentarios"
      assert html =~ comentario.contenido
    end

    test "saves new comentario", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/comentarios")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Comentario")
               |> render_click()
               |> follow_redirect(conn, ~p"/comentarios/new")

      assert render(form_live) =~ "New Comentario"

      assert form_live
             |> form("#comentario-form", comentario: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#comentario-form", comentario: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/comentarios")

      html = render(index_live)
      assert html =~ "Comentario created successfully"
      assert html =~ "some contenido"
    end

    test "updates comentario in listing", %{conn: conn, comentario: comentario} do
      {:ok, index_live, _html} = live(conn, ~p"/comentarios")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#comentarios-#{comentario.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/comentarios/#{comentario}/edit")

      assert render(form_live) =~ "Edit Comentario"

      assert form_live
             |> form("#comentario-form", comentario: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#comentario-form", comentario: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/comentarios")

      html = render(index_live)
      assert html =~ "Comentario updated successfully"
      assert html =~ "some updated contenido"
    end

    test "deletes comentario in listing", %{conn: conn, comentario: comentario} do
      {:ok, index_live, _html} = live(conn, ~p"/comentarios")

      assert index_live |> element("#comentarios-#{comentario.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#comentarios-#{comentario.id}")
    end
  end

  describe "Show" do
    setup [:create_comentario]

    test "displays comentario", %{conn: conn, comentario: comentario} do
      {:ok, _show_live, html} = live(conn, ~p"/comentarios/#{comentario}")

      assert html =~ "Show Comentario"
      assert html =~ comentario.contenido
    end

    test "updates comentario and returns to show", %{conn: conn, comentario: comentario} do
      {:ok, show_live, _html} = live(conn, ~p"/comentarios/#{comentario}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/comentarios/#{comentario}/edit?return_to=show")

      assert render(form_live) =~ "Edit Comentario"

      assert form_live
             |> form("#comentario-form", comentario: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#comentario-form", comentario: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/comentarios/#{comentario}")

      html = render(show_live)
      assert html =~ "Comentario updated successfully"
      assert html =~ "some updated contenido"
    end
  end
end
