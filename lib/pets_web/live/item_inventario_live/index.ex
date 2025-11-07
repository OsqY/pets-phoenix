defmodule PetsWeb.ItemInventarioLive.Index do
  use PetsWeb, :live_view

  alias Pets.Refugios

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Inventario
        <:actions>
          <.button variant="primary" navigate={~p"/refugio/inventario/crear-item"}>
            <.icon name="hero-plus" /> Crear Item
          </.button>
        </:actions>
      </.header>

      <.table
        id="items_inventario"
        rows={@streams.items_inventario}
        row_click={
          fn {_id, item_inventario} -> JS.navigate(~p"/refugio/inventario/#{item_inventario}") end
        }
      >
        <:col :let={{_id, item_inventario}} label="Nombre">{item_inventario.nombre}</:col>
        <:col :let={{_id, item_inventario}} label="Descripcion">{item_inventario.descripcion}</:col>
        <:col :let={{_id, item_inventario}} label="Cantidad">{item_inventario.cantidad}</:col>
        <:col :let={{_id, item_inventario}} label="Medida">{item_inventario.medida}</:col>
        <:col :let={{_id, item_inventario}} label="Tipo">{item_inventario.tipo}</:col>
        <:action :let={{_id, item_inventario}}>
          <div class="sr-only">
            <.link navigate={~p"/refugio/inventario/#{item_inventario}"}>Show</.link>
          </div>
          <.link navigate={~p"/refugio/inventario/#{item_inventario}/editar"}>Edit</.link>
        </:action>
        <:action :let={{id, item_inventario}}>
          <.link
            phx-click={JS.push("delete", value: %{id: item_inventario.id}) |> hide("##{id}")}
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
      Refugios.subscribe_items_inventario(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Inventario")
     |> stream(:items_inventario, list_items_inventario(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item_inventario = Refugios.get_item_inventario!(socket.assigns.current_scope, id)
    {:ok, _} = Refugios.delete_item_inventario(socket.assigns.current_scope, item_inventario)

    {:noreply, stream_delete(socket, :items_inventario, item_inventario)}
  end

  @impl true
  def handle_info({type, %Pets.Refugios.ItemInventario{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :items_inventario, list_items_inventario(socket.assigns.current_scope),
       reset: true
     )}
  end

  defp list_items_inventario(current_scope) do
    Refugios.list_items_inventario(current_scope)
  end
end
