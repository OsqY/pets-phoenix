defmodule PetsWeb.UsuarioLive.Registration do
  use PetsWeb, :live_view

  alias Pets.Cuentas
  alias Pets.Cuentas.Usuario

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <div class="text-center">
          <.header>
            Regístrese para crear una cuenta
            <:subtitle>
              ¿Ya tienes una cuenta?
              <.link navigate={~p"/usuario/log-in"} class="font-semibold text-brand hover:underline">
                Inicie Sesión
              </.link>
              en su cuenta ahora
            </:subtitle>
          </.header>
        </div>

        <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
          <.input
            field={@form[:email]}
            type="email"
            label="Correo electrónico"
            autocomplete="username"
            required
            phx-mounted={JS.focus()}
          />

          <.button phx-disable-with="Creando cuenta..." class="btn btn-primary w-full">
            Cree una cuenta
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{usuario: usuario}}} = socket)
      when not is_nil(usuario) do
    {:ok, redirect(socket, to: PetsWeb.UsuarioAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Cuentas.change_usuario_email(%Usuario{}, %{}, validate_unique: false)

    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"usuario" => usuario_params}, socket) do
    case Cuentas.register_usuario(usuario_params) do
      {:ok, usuario} ->
        {:ok, _} =
          Cuentas.deliver_login_instructions(
            usuario,
            &url(~p"/usuario/log-in/#{&1}")
          )

        {:noreply,
         socket
         |> put_flash(
           :info,
           "Un correo fue enviado a #{usuario.email}, por favor acceda a él para confirmar su cuenta."
         )
         |> push_navigate(to: ~p"/usuario/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"usuario" => usuario_params}, socket) do
    changeset = Cuentas.change_usuario_email(%Usuario{}, usuario_params, validate_unique: false)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "usuario")
    assign(socket, form: form)
  end
end
