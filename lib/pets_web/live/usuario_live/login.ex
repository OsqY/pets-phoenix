defmodule PetsWeb.UsuarioLive.Login do
  use PetsWeb, :live_view

  alias Pets.Cuentas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm space-y-4">
        <div class="text-center">
          <.header>
            <p>Iniciar Sesión</p>
            <:subtitle>
              <%= if @current_scope do %>
                Tienes que reautenticarte para hacer acciones sensibles en tu cuenta.
              <% else %>
                ¿No tienes una cuenta? <.link
                  navigate={~p"/usuario/registrarse"}
                  class="font-semibold text-brand hover:underline"
                  phx-no-format
                >Cree una cuenta</.link> ahora.
              <% end %>
            </:subtitle>
          </.header>
        </div>

        <div :if={local_mail_adapter?()} class="alert alert-info">
          <.icon name="hero-information-circle" class="size-6 shrink-0" />
          <div>
            <p>You are running the local mail adapter.</p>
            <p>
              To see sent emails, visit <.link href="/dev/mailbox" class="underline">the mailbox page</.link>.
            </p>
          </div>
        </div>

        <.form
          :let={f}
          for={@form}
          id="login_form_magic"
          action={~p"/usuario/iniciar-sesion"}
          phx-submit="submit_magic"
        >
          <.input
            readonly={!!@current_scope}
            field={f[:email]}
            type="email"
            label="Correo electrónico"
            autocomplete="username"
            required
            phx-mounted={JS.focus()}
          />
          <.button class="btn btn-primary w-full">
            Iniciar Sesión solo con correo electrónico<span aria-hidden="true">→</span>
          </.button>
        </.form>

        <div class="divider">or</div>

        <.form
          :let={f}
          for={@form}
          id="login_form_password"
          action={~p"/usuario/iniciar-sesion"}
          phx-submit="submit_password"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            readonly={!!@current_scope}
            field={f[:email]}
            type="email"
            label="Correo electrónico"
            autocomplete="username"
            required
          />
          <.input
            field={@form[:password]}
            type="password"
            label="Contraseña"
            autocomplete="current-password"
          />
          <.button class="btn btn-primary w-full" name={@form[:remember_me].name} value="true">
            Iniciar Sesión<span aria-hidden="true">→</span>
          </.button>
          <.button class="btn btn-primary btn-soft w-full mt-2">
            Iniciar Sesión solo esta vez
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:usuario), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "usuario")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"usuario" => %{"email" => email}}, socket) do
    if usuario = Cuentas.get_usuario_by_email(email) do
      Cuentas.deliver_login_instructions(
        usuario,
        &url(~p"/usuario/iniciar-sesion/#{&1}")
      )
    end

    info =
      "Si tu correo electrónico está en nuestro sistema, recibirás un correo con instrucciones para iniciar sesión."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/usuario/iniciar-sesion")}
  end

  defp local_mail_adapter? do
    Application.get_env(:pets, Pets.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
