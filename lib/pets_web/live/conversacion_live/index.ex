defmodule PetsWeb.ConversacionLive.Index do
  use PetsWeb, :live_view

  alias Pets.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Conversaciones
        <:actions>
          <.button variant="primary" navigate={~p"/conversaciones/new"}>
            <.icon name="hero-plus" /> New Conversacion
          </.button>
        </:actions>
      </.header>

      <.table
        id="conversaciones"
        rows={@streams.conversaciones}
        row_click={fn {_id, conversacion} -> JS.navigate(~p"/conversaciones/#{conversacion}") end}
      >
        <:col :let={{_id, conversacion}} label="Emisor">{conversacion.emisor_id}</:col>
        <:col :let={{_id, conversacion}} label="Receptor">{conversacion.receptor_id}</:col>
        <:action :let={{_id, conversacion}}>
          <div class="sr-only">
            <.link navigate={~p"/conversaciones/#{conversacion}"}>Show</.link>
          </div>
          <.link navigate={~p"/conversaciones/#{conversacion}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, conversacion}}>
          <.link
            phx-click={JS.push("delete", value: %{id: conversacion.id}) |> hide("##{id}")}
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
      Chats.subscribe_conversaciones(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Conversaciones")
     |> stream(:conversaciones, list_conversaciones(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    conversacion = Chats.get_conversacion!(socket.assigns.current_scope, id)
    {:ok, _} = Chats.delete_conversacion(socket.assigns.current_scope, conversacion)

    {:noreply, stream_delete(socket, :conversaciones, conversacion)}
  end

  @impl true
  def handle_info({type, %Pets.Chats.Conversacion{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :conversaciones, list_conversaciones(socket.assigns.current_scope), reset: true)}
  end

  defp list_conversaciones(current_scope) do
    Chats.list_conversaciones(current_scope)
  end
end
