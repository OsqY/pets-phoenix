defmodule PetsWeb.MensajeLive.Index do
  use PetsWeb, :live_view

  alias Pets.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Mensajes
        <:actions>
          <.button variant="primary" navigate={~p"/mensajes/new"}>
            <.icon name="hero-plus" /> New Mensaje
          </.button>
        </:actions>
      </.header>

      <.table
        id="mensajes"
        rows={@streams.mensajes}
        row_click={fn {_id, mensaje} -> JS.navigate(~p"/mensajes/#{mensaje}") end}
      >
        <:col :let={{_id, mensaje}} label="Contenido">{mensaje.contenido}</:col>
        <:col :let={{_id, mensaje}} label="Imagen">{mensaje.imagen}</:col>
        <:col :let={{_id, mensaje}} label="Fecha hora">{mensaje.fecha_hora}</:col>
        <:col :let={{_id, mensaje}} label="Emisor">{mensaje.emisor_id}</:col>
        <:col :let={{_id, mensaje}} label="Conversacion">{mensaje.conversacion_id}</:col>
        <:col :let={{_id, mensaje}} label="Leido">{mensaje.leido}</:col>
        <:action :let={{_id, mensaje}}>
          <div class="sr-only">
            <.link navigate={~p"/mensajes/#{mensaje}"}>Show</.link>
          </div>
          <.link navigate={~p"/mensajes/#{mensaje}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, mensaje}}>
          <.link
            phx-click={JS.push("delete", value: %{id: mensaje.id}) |> hide("##{id}")}
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
      Chats.subscribe_mensajes(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Mensajes")
     |> stream(:mensajes, list_mensajes(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    mensaje = Chats.get_mensaje!(socket.assigns.current_scope, id)
    {:ok, _} = Chats.delete_mensaje(socket.assigns.current_scope, mensaje)

    {:noreply, stream_delete(socket, :mensajes, mensaje)}
  end

  @impl true
  def handle_info({type, %Pets.Chats.Mensaje{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :mensajes, list_mensajes(socket.assigns.current_scope), reset: true)}
  end

  defp list_mensajes(current_scope) do
    Chats.list_mensajes(current_scope)
  end
end
