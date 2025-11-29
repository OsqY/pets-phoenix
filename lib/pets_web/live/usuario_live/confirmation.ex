defmodule PetsWeb.UsuarioLive.Confirmation do
  use PetsWeb, :live_view

  alias Pets.Cuentas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <div class="text-center">
          <.header>Bienvenido(a) {@usuario.email}</.header>
        </div>

        <.form
          :if={!@usuario.confirmed_at}
          for={@form}
          id="confirmation_form"
          phx-mounted={JS.focus_first()}
          phx-submit="submit"
          action={~p"/usuario/iniciar-sesion?_action=confirmed"}
          phx-trigger-action={@trigger_submit}
        >
          <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
          <.button
            name={@form[:remember_me].name}
            value="true"
            phx-disable-with="Confirmando..."
            class="btn btn-primary w-full"
          >
            Confirmar e Iniciar Sesión
          </.button>
          <.button phx-disable-with="Confirmando..." class="btn btn-primary btn-soft w-full mt-2">
            Confirmar e Iniciar Sesión solo esta vez
          </.button>
        </.form>

        <.form
          :if={@usuario.confirmed_at}
          for={@form}
          id="login_form"
          phx-submit="submit"
          phx-mounted={JS.focus_first()}
          action={~p"/usuario/iniciar-sesion"}
          phx-trigger-action={@trigger_submit}
        >
          <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
          <%= if @current_scope do %>
            <.button phx-disable-with="Iniciando sesión..." class="btn btn-primary w-full">
              Iniciar Sesión
            </.button>
          <% else %>
            <.button
              name={@form[:remember_me].name}
              value="true"
              phx-disable-with="Iniciando sesión..."
              class="btn btn-primary w-full"
            >
              Dejar mi cuenta iniciada en este dispositivo
            </.button>
            <.button
              phx-disable-with="Iniciando sesión..."
              class="btn btn-primary btn-soft w-full mt-2"
            >
              Iniciar Sesión solo esta vez
            </.button>
          <% end %>
        </.form>

        <p :if={!@usuario.confirmed_at} class="alert alert-outline mt-8">
          Tip: If you prefer passwords, you can enable them in the usuario settings.
        </p>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    if usuario = Cuentas.get_usuario_by_magic_link_token(token) do
      form = to_form(%{"token" => token}, as: "usuario")

      {:ok, assign(socket, usuario: usuario, form: form, trigger_submit: false),
       temporary_assigns: [form: nil]}
    else
      {:ok,
       socket
       |> put_flash(:error, "El enlace mágico es inválido o ha expirado.")
       |> push_navigate(to: ~p"/usuario/iniciar-sesion")}
    end
  end

  @impl true
  def handle_event("submit", %{"usuario" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: "usuario"), trigger_submit: true)}
  end
end
