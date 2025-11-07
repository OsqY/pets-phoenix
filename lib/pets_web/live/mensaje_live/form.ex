defmodule PetsWeb.MensajeLive.Form do
  use PetsWeb, :live_view

  alias Pets.Chats
  alias Pets.Chats.Mensaje

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage mensaje records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="mensaje-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:contenido]} type="textarea" label="Contenido" />
        <.input field={@form[:imagen]} type="text" label="Imagen" />
        <.input field={@form[:fecha_hora]} type="datetime-local" label="Fecha hora" />
        <.input field={@form[:emisor_id]} type="number" label="Emisor" />
        <.input field={@form[:conversacion_id]} type="number" label="Conversacion" />
        <.input field={@form[:leido]} type="checkbox" label="Leido" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Mensaje</.button>
          <.button navigate={return_path(@current_scope, @return_to, @mensaje)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    mensaje = Chats.get_mensaje!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Mensaje")
    |> assign(:mensaje, mensaje)
    |> assign(:form, to_form(Chats.change_mensaje(socket.assigns.current_scope, mensaje)))
  end

  defp apply_action(socket, :new, _params) do
    mensaje = %Mensaje{usuario_id: socket.assigns.current_scope.usuario.id}

    socket
    |> assign(:page_title, "New Mensaje")
    |> assign(:mensaje, mensaje)
    |> assign(:form, to_form(Chats.change_mensaje(socket.assigns.current_scope, mensaje)))
  end

  @impl true
  def handle_event("validate", %{"mensaje" => mensaje_params}, socket) do
    changeset = Chats.change_mensaje(socket.assigns.current_scope, socket.assigns.mensaje, mensaje_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"mensaje" => mensaje_params}, socket) do
    save_mensaje(socket, socket.assigns.live_action, mensaje_params)
  end

  defp save_mensaje(socket, :edit, mensaje_params) do
    case Chats.update_mensaje(socket.assigns.current_scope, socket.assigns.mensaje, mensaje_params) do
      {:ok, mensaje} ->
        {:noreply,
         socket
         |> put_flash(:info, "Mensaje updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, mensaje)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_mensaje(socket, :new, mensaje_params) do
    case Chats.create_mensaje(socket.assigns.current_scope, mensaje_params) do
      {:ok, mensaje} ->
        {:noreply,
         socket
         |> put_flash(:info, "Mensaje created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, mensaje)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _mensaje), do: ~p"/mensajes"
  defp return_path(_scope, "show", mensaje), do: ~p"/mensajes/#{mensaje}"
end
