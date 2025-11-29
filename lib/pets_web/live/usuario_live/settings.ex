defmodule PetsWeb.UsuarioLive.Settings do
  use PetsWeb, :live_view

  on_mount {PetsWeb.UsuarioAuth, :require_sudo_mode}

  alias Pets.Cuentas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="text-center">
        <.header>
          Account Settings
          <:subtitle>Manage your account email address and password settings</:subtitle>
        </.header>
      </div>

      <.form for={@email_form} id="email_form" phx-submit="update_email" phx-change="validate_email">
        <.input
          field={@email_form[:email]}
          type="email"
          label="Email"
          autocomplete="username"
          required
        />
        <.button variant="primary" phx-disable-with="Changing...">Change Email</.button>
      </.form>

      <div class="divider" />

      <.form
        for={@password_form}
        id="password_form"
        action={~p"/usuario/update-password"}
        method="post"
        phx-change="validate_password"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
      >
        <input
          name={@password_form[:email].name}
          type="hidden"
          id="hidden_usuario_email"
          autocomplete="username"
          value={@current_email}
        />
        <.input
          field={@password_form[:password]}
          type="password"
          label="New password"
          autocomplete="new-password"
          required
        />
        <.input
          field={@password_form[:password_confirmation]}
          type="password"
          label="Confirm new password"
          autocomplete="new-password"
        />
        <.button variant="primary" phx-disable-with="Saving...">
          Save Password
        </.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Cuentas.update_usuario_email(socket.assigns.current_scope.usuario, token) do
        {:ok, _usuario} ->
          put_flash(socket, :info, "Correo electrónico actualizado correctamente.")

        {:error, _} ->
          put_flash(socket, :error, "El enlace de cambio de correo es inválido o ha expirado.")
      end

    {:ok, push_navigate(socket, to: ~p"/usuario/configuracion")}
  end

  def mount(_params, _session, socket) do
    usuario = socket.assigns.current_scope.usuario
    email_changeset = Cuentas.change_usuario_email(usuario, %{}, validate_unique: false)
    password_changeset = Cuentas.change_usuario_password(usuario, %{}, hash_password: false)

    socket =
      socket
      |> assign(:current_email, usuario.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_email", params, socket) do
    %{"usuario" => usuario_params} = params

    email_form =
      socket.assigns.current_scope.usuario
      |> Cuentas.change_usuario_email(usuario_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"usuario" => usuario_params} = params
    usuario = socket.assigns.current_scope.usuario
    true = Cuentas.sudo_mode?(usuario)

    case Cuentas.change_usuario_email(usuario, usuario_params) do
      %{valid?: true} = changeset ->
        Cuentas.deliver_usuario_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          usuario.email,
          &url(~p"/usuario/configuracion/confirmar-email/#{&1}")
        )

        info = "Se ha enviado un enlace de confirmación a la nueva dirección de correo."
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"usuario" => usuario_params} = params

    password_form =
      socket.assigns.current_scope.usuario
      |> Cuentas.change_usuario_password(usuario_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", params, socket) do
    %{"usuario" => usuario_params} = params
    usuario = socket.assigns.current_scope.usuario
    true = Cuentas.sudo_mode?(usuario)

    case Cuentas.change_usuario_password(usuario, usuario_params) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}

      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end
end
