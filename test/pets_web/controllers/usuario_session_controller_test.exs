defmodule PetsWeb.UsuarioSessionControllerTest do
  use PetsWeb.ConnCase, async: true

  import Pets.CuentasFixtures
  alias Pets.Cuentas

  setup do
    %{unconfirmed_usuario: unconfirmed_usuario_fixture(), usuario: usuario_fixture()}
  end

  describe "POST /usuario/log-in - email and password" do
    test "logs the usuario in", %{conn: conn, usuario: usuario} do
      usuario = set_password(usuario)

      conn =
        post(conn, ~p"/usuario/log-in", %{
          "usuario" => %{"email" => usuario.email, "password" => valid_usuario_password()}
        })

      assert get_session(conn, :usuario_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ usuario.email
      assert response =~ ~p"/usuario/settings"
      assert response =~ ~p"/usuario/log-out"
    end

    test "logs the usuario in with remember me", %{conn: conn, usuario: usuario} do
      usuario = set_password(usuario)

      conn =
        post(conn, ~p"/usuario/log-in", %{
          "usuario" => %{
            "email" => usuario.email,
            "password" => valid_usuario_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_pets_web_usuario_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the usuario in with return to", %{conn: conn, usuario: usuario} do
      usuario = set_password(usuario)

      conn =
        conn
        |> init_test_session(usuario_return_to: "/foo/bar")
        |> post(~p"/usuario/log-in", %{
          "usuario" => %{
            "email" => usuario.email,
            "password" => valid_usuario_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "redirects to login page with invalid credentials", %{conn: conn, usuario: usuario} do
      conn =
        post(conn, ~p"/usuario/log-in?mode=password", %{
          "usuario" => %{"email" => usuario.email, "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == ~p"/usuario/log-in"
    end
  end

  describe "POST /usuario/log-in - magic link" do
    test "logs the usuario in", %{conn: conn, usuario: usuario} do
      {token, _hashed_token} = generate_usuario_magic_link_token(usuario)

      conn =
        post(conn, ~p"/usuario/log-in", %{
          "usuario" => %{"token" => token}
        })

      assert get_session(conn, :usuario_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ usuario.email
      assert response =~ ~p"/usuario/settings"
      assert response =~ ~p"/usuario/log-out"
    end

    test "confirms unconfirmed usuario", %{conn: conn, unconfirmed_usuario: usuario} do
      {token, _hashed_token} = generate_usuario_magic_link_token(usuario)
      refute usuario.confirmed_at

      conn =
        post(conn, ~p"/usuario/log-in", %{
          "usuario" => %{"token" => token},
          "_action" => "confirmed"
        })

      assert get_session(conn, :usuario_token)
      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Usuario confirmed successfully."

      assert Cuentas.get_usuario!(usuario.id).confirmed_at

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ usuario.email
      assert response =~ ~p"/usuario/settings"
      assert response =~ ~p"/usuario/log-out"
    end

    test "redirects to login page when magic link is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/usuario/log-in", %{
          "usuario" => %{"token" => "invalid"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "The link is invalid or it has expired."

      assert redirected_to(conn) == ~p"/usuario/log-in"
    end
  end

  describe "DELETE /usuario/log-out" do
    test "logs the usuario out", %{conn: conn, usuario: usuario} do
      conn = conn |> log_in_usuario(usuario) |> delete(~p"/usuario/log-out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :usuario_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the usuario is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/usuario/log-out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :usuario_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
