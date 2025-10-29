defmodule PetsWeb.UsuarioSessionController do
  use PetsWeb, :controller

  alias Pets.Cuentas
  alias PetsWeb.UsuarioAuth

  def create(conn, %{"_action" => "confirmed"} = params) do
    create(conn, params, "Usuario confirmado.")
  end

  def create(conn, params) do
    create(conn, params, "Bienvenido(a) devuelta!")
  end

  # magic link login
  defp create(conn, %{"usuario" => %{"token" => token} = usuario_params}, info) do
    case Cuentas.login_usuario_by_magic_link(token) do
      {:ok, {usuario, tokens_to_disconnect}} ->
        UsuarioAuth.disconnect_sessions(tokens_to_disconnect)

        conn
        |> put_flash(:info, info)
        |> UsuarioAuth.log_in_usuario(usuario, usuario_params)

      _ ->
        conn
        |> put_flash(:error, "El enlace es inválido o ha expirado.")
        |> redirect(to: ~p"/usuario/log-in")
    end
  end

  # email + password login
  defp create(conn, %{"usuario" => usuario_params}, info) do
    %{"email" => email, "password" => password} = usuario_params

    if usuario = Cuentas.get_usuario_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UsuarioAuth.log_in_usuario(usuario, usuario_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/usuario/log-in")
    end
  end

  def update_password(conn, %{"usuario" => usuario_params} = params) do
    usuario = conn.assigns.current_scope.usuario
    true = Cuentas.sudo_mode?(usuario)
    {:ok, {_usuario, expired_tokens}} = Cuentas.update_usuario_password(usuario, usuario_params)

    # disconnect all existing LiveViews with old sessions
    UsuarioAuth.disconnect_sessions(expired_tokens)

    conn
    |> put_session(:usuario_return_to, ~p"/usuario/settings")
    |> create(params, "Contraseña actualizada.")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Sesión cerrada.")
    |> UsuarioAuth.log_out_usuario()
  end
end
