defmodule PetsWeb.ComentarioLive.Index do
  use PetsWeb, :live_view

  alias Pets.Posts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Lista de Comentarios
        <:actions>
          <.button variant="primary" navigate={~p"/comentarios/new"}>
            <.icon name="hero-plus" /> Nuevo Comentario
          </.button>
        </:actions>
      </.header>

      <.table
        id="comentarios"
        rows={@streams.comentarios}
        row_click={fn {_id, comentario} -> JS.navigate(~p"/comentarios/#{comentario}") end}
      >
        <:col :let={{_id, comentario}} label="Contenido">{comentario.contenido}</:col>
        <:col :let={{_id, comentario}} label="Usuario">{comentario.usuario_id}</:col>
        <:col :let={{_id, comentario}} label="Likes">{comentario.likes}</:col>
        <:action :let={{_id, comentario}}>
          <div class="sr-only">
            <.link navigate={~p"/comentarios/#{comentario}"}>Ver</.link>
          </div>
          <.link navigate={~p"/comentarios/#{comentario}/edit"}>Editar</.link>
        </:action>
        <:action :let={{id, comentario}}>
          <.link
            phx-click={JS.push("delete", value: %{id: comentario.id}) |> hide("##{id}")}
            data-confirm="¿Estás seguro?"
          >
            Eliminar
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Posts.subscribe_comentarios(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Lista de Comentarios")
     |> stream(:comentarios, list_comentarios(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    comentario = Posts.get_comentario!(socket.assigns.current_scope, id)
    {:ok, _} = Posts.delete_comentario(socket.assigns.current_scope, comentario)

    {:noreply, stream_delete(socket, :comentarios, comentario)}
  end

  @impl true
  def handle_info({type, %Pets.Posts.Comentario{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :comentarios, list_comentarios(socket.assigns.current_scope), reset: true)}
  end

  defp list_comentarios(current_scope) do
    Posts.list_comentarios(current_scope)
  end
end
