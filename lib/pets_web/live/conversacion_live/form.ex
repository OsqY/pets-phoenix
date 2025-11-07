defmodule PetsWeb.ConversacionLive.Form do
  use PetsWeb, :live_view

  alias Pets.Chats
  alias Pets.Chats.Conversacion

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage conversacion records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="conversacion-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:emisor_id]} type="number" label="Emisor" />
        <.input field={@form[:receptor_id]} type="number" label="Receptor" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Conversacion</.button>
          <.button navigate={return_path(@current_scope, @return_to, @conversacion)}>Cancel</.button>
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
    conversacion = Chats.get_conversacion!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Conversacion")
    |> assign(:conversacion, conversacion)
    |> assign(:form, to_form(Chats.change_conversacion(socket.assigns.current_scope, conversacion)))
  end

  defp apply_action(socket, :new, _params) do
    conversacion = %Conversacion{usuario_id: socket.assigns.current_scope.usuario.id}

    socket
    |> assign(:page_title, "New Conversacion")
    |> assign(:conversacion, conversacion)
    |> assign(:form, to_form(Chats.change_conversacion(socket.assigns.current_scope, conversacion)))
  end

  @impl true
  def handle_event("validate", %{"conversacion" => conversacion_params}, socket) do
    changeset = Chats.change_conversacion(socket.assigns.current_scope, socket.assigns.conversacion, conversacion_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"conversacion" => conversacion_params}, socket) do
    save_conversacion(socket, socket.assigns.live_action, conversacion_params)
  end

  defp save_conversacion(socket, :edit, conversacion_params) do
    case Chats.update_conversacion(socket.assigns.current_scope, socket.assigns.conversacion, conversacion_params) do
      {:ok, conversacion} ->
        {:noreply,
         socket
         |> put_flash(:info, "Conversacion updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, conversacion)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_conversacion(socket, :new, conversacion_params) do
    case Chats.create_conversacion(socket.assigns.current_scope, conversacion_params) do
      {:ok, conversacion} ->
        {:noreply,
         socket
         |> put_flash(:info, "Conversacion created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, conversacion)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _conversacion), do: ~p"/conversaciones"
  defp return_path(_scope, "show", conversacion), do: ~p"/conversaciones/#{conversacion}"
end
