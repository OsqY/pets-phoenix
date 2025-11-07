defmodule PetsWeb.NotificacionLive.Index do
  use PetsWeb, :live_view

  alias Pets.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Notificaciones
        <:actions>
          <.button variant="primary" navigate={~p"/notificaciones/new"}>
            <.icon name="hero-plus" /> New Notificacion
          </.button>
        </:actions>
      </.header>

      <.table
        id="notificaciones"
        rows={@streams.notificaciones}
        row_click={fn {_id, notificacion} -> JS.navigate(~p"/notificaciones/#{notificacion}") end}
      >
        <:col :let={{_id, notificacion}} label="Contenido">{notificacion.contenido}</:col>
        <:col :let={{_id, notificacion}} label="Fehca">{notificacion.fehca}</:col>
        <:action :let={{_id, notificacion}}>
          <div class="sr-only">
            <.link navigate={~p"/notificaciones/#{notificacion}"}>Show</.link>
          </div>
          <.link navigate={~p"/notificaciones/#{notificacion}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, notificacion}}>
          <.link
            phx-click={JS.push("delete", value: %{id: notificacion.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Chats.subscribe_notificaciones(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Notificaciones")
     |> stream(:notificaciones, list_notificaciones(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    notificacion = Chats.get_notificacion!(socket.assigns.current_scope, id)
    {:ok, _} = Chats.delete_notificacion(socket.assigns.current_scope, notificacion)

    {:noreply, stream_delete(socket, :notificaciones, notificacion)}
  end

  @impl true
  def handle_info({type, %Pets.Chats.Notificacion{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :notificaciones, list_notificaciones(socket.assigns.current_scope), reset: true)}
  end

  defp list_notificaciones(current_scope) do
    Chats.list_notificaciones(current_scope)
  end
end
