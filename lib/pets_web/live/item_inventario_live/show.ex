defmodule PetsWeb.ItemInventarioLive.Show do
  use PetsWeb, :live_view

  alias Pets.Refugios

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Item inventario {@item_inventario.id}
        <:subtitle>Item</:subtitle>
        <:actions>
          <.button navigate={~p"/refugio/inventario"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/refugio/inventario/#{@item_inventario}/editar-item?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Editar Item
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Nombre">{@item_inventario.nombre}</:item>
        <:item title="Descripcion">{@item_inventario.descripcion}</:item>
        <:item title="Cantidad">{@item_inventario.cantidad}</:item>
        <:item title="Refugio">{@item_inventario.refugio_id}</:item>
        <:item title="Medida">{@item_inventario.medida}</:item>
        <:item title="Tipo">{@item_inventario.tipo}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Refugios.subscribe_items_inventario(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Item inventario")
     |> assign(:item_inventario, Refugios.get_item_inventario!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Refugios.ItemInventario{id: id} = item_inventario},
        %{assigns: %{item_inventario: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :item_inventario, item_inventario)}
  end

  def handle_info(
        {:deleted, %Pets.Refugios.ItemInventario{id: id}},
        %{assigns: %{item_inventario: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current item_inventario was deleted.")
     |> push_navigate(to: ~p"/items_inventario")}
  end

  def handle_info({type, %Pets.Refugios.ItemInventario{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
