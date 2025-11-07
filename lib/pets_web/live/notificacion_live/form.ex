defmodule PetsWeb.NotificacionLive.Form do
  use PetsWeb, :live_view

  alias Pets.Chats
  alias Pets.Chats.Notificacion

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage notificacion records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="notificacion-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:contenido]} type="textarea" label="Contenido" />
        <.input field={@form[:fehca]} type="datetime-local" label="Fehca" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Notificacion</.button>
          <.button navigate={return_path(@current_scope, @return_to, @notificacion)}>Cancel</.button>
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
    notificacion = Chats.get_notificacion!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Notificacion")
    |> assign(:notificacion, notificacion)
    |> assign(:form, to_form(Chats.change_notificacion(socket.assigns.current_scope, notificacion)))
  end

  defp apply_action(socket, :new, _params) do
    notificacion = %Notificacion{usuario_id: socket.assigns.current_scope.usuario.id}

    socket
    |> assign(:page_title, "New Notificacion")
    |> assign(:notificacion, notificacion)
    |> assign(:form, to_form(Chats.change_notificacion(socket.assigns.current_scope, notificacion)))
  end

  @impl true
  def handle_event("validate", %{"notificacion" => notificacion_params}, socket) do
    changeset = Chats.change_notificacion(socket.assigns.current_scope, socket.assigns.notificacion, notificacion_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"notificacion" => notificacion_params}, socket) do
    save_notificacion(socket, socket.assigns.live_action, notificacion_params)
  end

  defp save_notificacion(socket, :edit, notificacion_params) do
    case Chats.update_notificacion(socket.assigns.current_scope, socket.assigns.notificacion, notificacion_params) do
      {:ok, notificacion} ->
        {:noreply,
         socket
         |> put_flash(:info, "Notificacion updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, notificacion)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_notificacion(socket, :new, notificacion_params) do
    case Chats.create_notificacion(socket.assigns.current_scope, notificacion_params) do
      {:ok, notificacion} ->
        {:noreply,
         socket
         |> put_flash(:info, "Notificacion created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, notificacion)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _notificacion), do: ~p"/notificaciones"
  defp return_path(_scope, "show", notificacion), do: ~p"/notificaciones/#{notificacion}"
end
