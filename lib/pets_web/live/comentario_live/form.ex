defmodule PetsWeb.ComentarioLive.Form do
  use PetsWeb, :live_view

  alias Pets.Posts
  alias Pets.Posts.Comentario

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage comentario records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="comentario-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:contenido]} type="textarea" label="Contenido" />
        <.input field={@form[:usuario_id]} type="number" label="Usuario" />
        <.input field={@form[:likes]} type="number" label="Likes" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Comentario</.button>
          <.button navigate={return_path(@current_scope, @return_to, @comentario)}>Cancel</.button>
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
    comentario = Posts.get_comentario!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Comentario")
    |> assign(:comentario, comentario)
    |> assign(:form, to_form(Posts.change_comentario(socket.assigns.current_scope, comentario)))
  end

  defp apply_action(socket, :new, _params) do
    comentario = %Comentario{usuario_id: socket.assigns.current_scope.usuario.id}

    socket
    |> assign(:page_title, "New Comentario")
    |> assign(:comentario, comentario)
    |> assign(:form, to_form(Posts.change_comentario(socket.assigns.current_scope, comentario)))
  end

  @impl true
  def handle_event("validate", %{"comentario" => comentario_params}, socket) do
    changeset = Posts.change_comentario(socket.assigns.current_scope, socket.assigns.comentario, comentario_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"comentario" => comentario_params}, socket) do
    save_comentario(socket, socket.assigns.live_action, comentario_params)
  end

  defp save_comentario(socket, :edit, comentario_params) do
    case Posts.update_comentario(socket.assigns.current_scope, socket.assigns.comentario, comentario_params) do
      {:ok, comentario} ->
        {:noreply,
         socket
         |> put_flash(:info, "Comentario actualizado con éxito")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, comentario)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_comentario(socket, :new, comentario_params) do
    case Posts.create_comentario(socket.assigns.current_scope, comentario_params) do
      {:ok, comentario} ->
        {:noreply,
         socket
         |> put_flash(:info, "Comentario creado con éxito")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, comentario)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _comentario), do: ~p"/comentarios"
  defp return_path(_scope, "show", comentario), do: ~p"/comentarios/#{comentario}"
end
